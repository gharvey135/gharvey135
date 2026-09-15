# Self-hosting NetBird

`install-netbird.sh` runs the preflight checks that catch the usual failures, then
hands off to NetBird's own [`getting-started.sh`][quickstart] installer.

It has to run **on the server**, not on a laptop and not in a Claude Code web
session — those are short-lived sandboxes with no public IP or domain, so they
cannot host something other devices connect to.

## What you need first

- A Linux server (Ubuntu/Debian/Fedora all fine) with a **public IP**, 2 vCPU /
  2 GB RAM is plenty for a homelab.
- A domain, e.g. `netbird.example.com`, with an **A record pointing at that IP**.
- Inbound firewall openings for `80/tcp`, `443/tcp`, `3478/udp`.
- Root (or sudo) on the box.

## Install

```bash
# on the server
curl -fsSLO https://raw.githubusercontent.com/gharvey135/gharvey135/main/netbird/install-netbird.sh
sudo NETBIRD_DOMAIN=netbird.example.com \
     NETBIRD_LETSENCRYPT_EMAIL=you@example.com \
     bash install-netbird.sh
```

Or just `sudo bash install-netbird.sh` and it prompts for the two values.

The script will:

1. Check that the domain's A record resolves to this host's public IP.
2. Check that `80/tcp`, `443/tcp` and `3478/udp` have no existing listener.
3. Check for Docker, the Compose plugin, `jq` and `openssl` — offering to
   install any that are missing.
4. Download the upstream installer into `/opt/netbird` (override with
   `NETBIRD_WORKDIR`), print its SHA-256, and run it unattended.

Nothing is installed until the preflight passes and you confirm.

## After it finishes

1. Open `https://<your-domain>` and follow the onboarding to create the first
   admin account. Current NetBird ships an **embedded Dex identity provider**,
   so there is no separate Zitadel setup step and no `/setup` URL — older guides
   that mention those describe the retired
   `getting-started-with-zitadel.sh` flow.
2. On each device: `netbird up --management-url https://<your-domain>`
3. Manage the stack from `/opt/netbird`:
   ```bash
   docker compose ps
   docker compose logs -f
   docker compose restart
   ```

TLS warnings in the first minute are normal while Let's Encrypt issues the
certificate. If they persist, `docker compose logs traefik` says why — almost
always DNS or a blocked port 80.

## Already running a reverse proxy?

The default (`NETBIRD_REVERSE_PROXY_TYPE=0`) starts NetBird's own Traefik, which
wants 80 and 443 to itself. If nginx, Caddy, Traefik or Nginx Proxy Manager
already owns those ports, set the type before running:

| Value | Front end                 |
|-------|---------------------------|
| `0`   | Built-in Traefik (default)|
| `1`   | Your existing Traefik     |
| `2`   | Nginx                     |
| `3`   | Nginx Proxy Manager       |
| `4`   | Caddy                     |
| `5`   | Manual — prints the config|

```bash
sudo NETBIRD_REVERSE_PROXY_TYPE=2 NETBIRD_DOMAIN=... NETBIRD_LETSENCRYPT_EMAIL=... \
  bash install-netbird.sh
```

The upstream installer prints the reverse-proxy config to paste in once it's done.

[quickstart]: https://docs.netbird.io/selfhosted/selfhosted-quickstart

## Escape hatches

| Variable | Effect |
|----------|--------|
| `SKIP_DNS_CHECK=true` | Skip the A-record match — for a host behind a load balancer that owns the public address |
| `NETBIRD_WORKDIR=/srv/netbird` | Install somewhere other than `/opt/netbird` |
| `ASSUME_YES=true` | Answer every prompt yes (unattended) |
