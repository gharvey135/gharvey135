#!/usr/bin/env bash
#
# install-netbird.sh — preflight checks + self-hosted NetBird install.
#
# Run this ON the Linux server that will host NetBird (not on your laptop):
#
#   sudo NETBIRD_DOMAIN=netbird.example.com \
#        NETBIRD_LETSENCRYPT_EMAIL=you@example.com \
#        bash install-netbird.sh
#
# Or interactively:  sudo bash install-netbird.sh
#
# What it does:
#   1. Verifies the domain's A record points at this server's public IP.
#   2. Verifies ports 80/tcp, 443/tcp and 3478/udp are free.
#   3. Verifies (and optionally installs) Docker, Docker Compose, jq, openssl.
#   4. Downloads NetBird's official getting-started.sh and runs it unattended.
#
# The install itself is NetBird's own upstream script — this wrapper only checks
# the things that make that script fail halfway through, and prints the fix.
#
# Docs: https://docs.netbird.io/selfhosted/selfhosted-quickstart

set -euo pipefail

INSTALLER_URL="https://github.com/netbirdio/netbird/releases/latest/download/getting-started.sh"
WORKDIR="${NETBIRD_WORKDIR:-/opt/netbird}"
ASSUME_YES="${ASSUME_YES:-false}"

red()  { printf '\033[31m%s\033[0m\n' "$*"; }
grn()  { printf '\033[32m%s\033[0m\n' "$*"; }
ylw()  { printf '\033[33m%s\033[0m\n' "$*"; }
bold() { printf '\033[1m%s\033[0m\n' "$*"; }

ok()   { grn "  ok    $*"; }
warn() { ylw "  warn  $*"; }
fail() { red "  FAIL  $*"; FAILED=1; }

FAILED=0

confirm() {
  [[ "$ASSUME_YES" == "true" ]] && return 0
  local reply
  read -r -p "$1 [y/N] " reply </dev/tty
  [[ "$reply" =~ ^[Yy]$ ]]
}

require_root() {
  if [[ "$(id -u)" -ne 0 ]]; then
    red "Run this as root (sudo bash $0)."
    exit 1
  fi
}

# ---------------------------------------------------------------- inputs ----

read_inputs() {
  if [[ -z "${NETBIRD_DOMAIN:-}" ]]; then
    read -r -p "Domain for this NetBird server (e.g. netbird.example.com): " NETBIRD_DOMAIN </dev/tty
  fi
  if [[ -z "${NETBIRD_LETSENCRYPT_EMAIL:-}" ]]; then
    read -r -p "Email for Let's Encrypt certificate notices: " NETBIRD_LETSENCRYPT_EMAIL </dev/tty
  fi

  if [[ -z "$NETBIRD_DOMAIN" || "$NETBIRD_DOMAIN" == "netbird.example.com" ]]; then
    red "NETBIRD_DOMAIN must be your real FQDN."
    exit 1
  fi
  if [[ "$NETBIRD_DOMAIN" =~ ^[0-9.]+$ ]]; then
    red "NETBIRD_DOMAIN is an IP address. Use a real FQDN so Let's Encrypt can issue a certificate."
    exit 1
  fi
  if [[ -z "$NETBIRD_LETSENCRYPT_EMAIL" ]]; then
    red "NETBIRD_LETSENCRYPT_EMAIL is required (Let's Encrypt needs a contact address)."
    exit 1
  fi
  export NETBIRD_DOMAIN NETBIRD_LETSENCRYPT_EMAIL
}

# ------------------------------------------------------------- preflight ----

public_ip() {
  local ip
  for url in https://api.ipify.org https://ifconfig.me/ip https://icanhazip.com; do
    ip="$(curl -fsS --max-time 8 "$url" 2>/dev/null | tr -d '[:space:]')" || continue
    [[ -n "$ip" ]] && { echo "$ip"; return 0; }
  done
  return 1
}

resolve_a() {
  if command -v dig >/dev/null 2>&1; then
    dig +short A "$1" @1.1.1.1 2>/dev/null | grep -E '^[0-9.]+$' || true
  elif command -v host >/dev/null 2>&1; then
    host -t A "$1" 2>/dev/null | awk '/has address/ {print $NF}' || true
  else
    getent ahostsv4 "$1" 2>/dev/null | awk '{print $1}' | sort -u || true
  fi
}

check_dns() {
  bold "DNS"
  local ips myip
  ips="$(resolve_a "$NETBIRD_DOMAIN")"
  myip="$(public_ip || true)"

  if [[ -z "$ips" ]]; then
    fail "$NETBIRD_DOMAIN has no A record. Create one pointing at this server before installing."
    [[ -n "$myip" ]] && echo "        this server's public IP looks like: $myip"
    return
  fi
  ok "$NETBIRD_DOMAIN -> $(echo "$ips" | tr '\n' ' ')"

  if [[ -z "$myip" ]]; then
    warn "could not determine this server's public IP (no outbound HTTPS?); skipping the match check"
  elif grep -qx "$myip" <<<"$ips"; then
    ok "A record matches this server's public IP ($myip)"
  else
    fail "A record does not point at this server (this host is $myip). Fix DNS and wait for TTL."
  fi
}

check_ports() {
  bold "Ports"
  if ! command -v ss >/dev/null 2>&1; then
    warn "ss not found (install iproute2); skipping listener check"
  else
    local listeners
    for spec in "tcp 80" "tcp 443" "udp 3478"; do
      set -- $spec
      listeners="$(ss -lntup 2>/dev/null | awk -v p=":$2\$" -v pr="$1" '$1==pr && $5 ~ p {print $NF}' | sort -u | tr '\n' ' ')"
      if [[ -n "$listeners" ]]; then
        fail "$1/$2 is already in use by: $listeners — stop it or use an external reverse proxy (see README)"
      else
        ok "$1/$2 is free"
      fi
    done
  fi
  echo "        Also open these inbound in your cloud firewall / security group:"
  echo "          80/tcp   HTTP (Let's Encrypt challenge, redirects to HTTPS)"
  echo "          443/tcp  HTTPS — dashboard, API, signal, relay"
  echo "          3478/udp STUN — NAT traversal"
}

install_docker() {
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sh /tmp/get-docker.sh
  systemctl enable --now docker 2>/dev/null || true
}

pkg_install() {
  if command -v apt-get >/dev/null 2>&1; then
    apt-get update -qq && apt-get install -y "$@"
  elif command -v dnf >/dev/null 2>&1; then
    dnf install -y "$@"
  elif command -v yum >/dev/null 2>&1; then
    yum install -y "$@"
  else
    return 1
  fi
}

check_deps() {
  bold "Dependencies"

  if command -v docker >/dev/null 2>&1; then
    ok "docker $(docker --version | awk '{print $3}' | tr -d ,)"
  else
    warn "docker is not installed"
    if confirm "  Install Docker now via get.docker.com?"; then
      install_docker && ok "docker installed"
    else
      fail "docker is required — https://docs.docker.com/engine/install/"
    fi
  fi

  if docker compose version >/dev/null 2>&1; then
    ok "docker compose $(docker compose version --short 2>/dev/null)"
  elif command -v docker-compose >/dev/null 2>&1; then
    ok "docker-compose (v1) present"
  else
    fail "docker compose plugin missing — https://docs.docker.com/compose/install/"
  fi

  for bin in jq openssl curl; do
    if command -v "$bin" >/dev/null 2>&1; then
      ok "$bin"
    else
      warn "$bin is not installed"
      if confirm "  Install $bin now?"; then
        pkg_install "$bin" && ok "$bin installed" || fail "could not install $bin automatically"
      else
        fail "$bin is required"
      fi
    fi
  done

  if command -v systemctl >/dev/null 2>&1 && ! systemctl is-active --quiet docker; then
    fail "the docker daemon is not running (systemctl start docker)"
  fi
}

# --------------------------------------------------------------- install ----

run_installer() {
  bold "Installing NetBird"
  mkdir -p "$WORKDIR"
  cd "$WORKDIR"

  curl -fsSL "$INSTALLER_URL" -o getting-started.sh
  echo "  downloaded $INSTALLER_URL"
  echo "  sha256: $(sha256sum getting-started.sh | awk '{print $1}')"
  echo "  running in $WORKDIR (docker-compose.yml and secrets are written here)"
  echo

  NETBIRD_NON_INTERACTIVE=true \
  NETBIRD_REVERSE_PROXY_TYPE="${NETBIRD_REVERSE_PROXY_TYPE:-0}" \
  NETBIRD_DOMAIN="$NETBIRD_DOMAIN" \
  NETBIRD_LETSENCRYPT_EMAIL="$NETBIRD_LETSENCRYPT_EMAIL" \
    bash getting-started.sh
}

main() {
  require_root
  read_inputs

  bold "NetBird preflight for $NETBIRD_DOMAIN"
  echo
  check_dns
  echo
  check_ports
  echo
  check_deps
  echo

  if [[ "$FAILED" -ne 0 ]]; then
    red "Preflight failed. Fix the items marked FAIL above and re-run."
    exit 1
  fi
  grn "Preflight passed."
  echo

  if ! confirm "Install NetBird into $WORKDIR now?"; then
    echo "Stopping here. Nothing was installed."
    exit 0
  fi
  run_installer

  echo
  bold "Next steps"
  echo "  1. Open https://$NETBIRD_DOMAIN and follow the onboarding to create the"
  echo "     first admin account (the embedded Dex IdP is set up for you)."
  echo "  2. Install the NetBird client on your devices and point it at this server:"
  echo "       netbird up --management-url https://$NETBIRD_DOMAIN"
  echo "  3. Manage the stack with:  cd $WORKDIR && docker compose ps|logs -f|restart"
  echo
  echo "  Certificates take a few seconds to issue — a TLS warning right after"
  echo "  install usually clears on its own. If it does not, check:"
  echo "       cd $WORKDIR && docker compose logs traefik"
}

main "$@"
