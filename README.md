# Georgia Harvey

Solutions architect, sales engineer, forward deployed engineer. Eight years shipping enterprise integrations and AI workflows end to end: discovery, architecture, build, launch, and the handoff that makes them stick. I also co-own two Austin venues, which is why several repos here reconcile reservations, POS checks, and HR paperwork instead of todo lists.

Previously: AI Technical Lead and North America Solutions Architect at Productboard, Technical Account Manager for 150+ enterprise API accounts at Perigon, Implementation Lead at Melio Payments, Product Operations at Sentieo (AlphaSense).

Portfolio: [georgia-sa-portfolio.vercel.app](https://georgia-sa-portfolio.vercel.app)  ·  [LinkedIn](https://www.linkedin.com/in/georgia-harvey/)  ·  Email: gharvey135@gmail.com

## Start here

| Repo | What it is | Stack | Proof |
| --- | --- | --- | --- |
| [venue-integration](https://github.com/gharvey135/venue-integration) | Reservations-to-POS reconciliation for a nightclub group: TableList reservations matched to Union and Toast checks with an explainable scoring engine; table minimums, no-shows, revenue by section, deposit reconciliation. In use at my venues. | TypeScript, Node 22, SQLite, zero runtime deps | 117 offline tests, `npm run demo` runs the whole pipeline on a recorded night |
| [venue-spend-demo](https://github.com/gharvey135/venue-table-spend-demo) | Which bottle-service tables hit their minimum on a business date, and what they ordered. Walks Toast orders to checks to selections and groups by table, because the POS Shift Review screen cannot answer the question; every money identity verified against the API. Public version of a nightly tool I run at my venues. [Live demo](https://gharvey135.github.io/venue-table-spend-demo/), [case study](https://github.com/gharvey135/venue-table-spend-demo/blob/main/docs/case-study.md). | Python, one dependency | 41 tests, synthetic Toast-shaped fixture, `python -m table_spend.table_spend 20260904` runs with zero setup |
| [integration-patterns](https://github.com/gharvey135/integration-patterns) | Seven primitives every enterprise integration needs, written once with the edge cases as tests: webhook verification, idempotency keys, retry with backoff, token-bucket rate limiting, pagination, circuit breaker, transactional outbox. | TypeScript, zero runtime deps | 75 tests, each module documents the production incident it prevents |
| [api-contract-diff](https://github.com/gharvey135/api-contract-diff) | CLI that diffs two OpenAPI specs and classifies every change as breaking, warning, or info. Exits non-zero on breaking changes so it can gate a release. Built because unannounced breaking changes were my top escalation source as a TAM. | Python, one dependency | 17 breaking rules, 50 tests |
| [data-underwriting-example](https://github.com/gharvey135/data-underwriting-example) | Five-stage address intelligence pipeline for insurance underwriting: verification, geocoding, PreciselyID, location risk enrichment, LLM risk narratives, and a VP-facing impact summary. Take-home for a Senior SE interview, run against the live API. | Python | 466 of 500 dirty addresses confirmed with zero manual review, 53 tests |
| [hr-compliance-automation](https://github.com/gharvey135/hr-compliance-automation) | Weekly HR/TABC compliance tracker: scanned documents in Dropbox become a one-row-per-employee snapshot in Google Sheets plus expiry alerts. Production for about 70 employees and 20 contractors across two venues; this is the de-identified version. [Live demo](https://gharvey135.github.io/hr-compliance-automation/), [case study](https://github.com/gharvey135/hr-compliance-automation/blob/main/docs/case-study.md). | Python, Google Apps Script, scheduled Claude task | 53 tests, sample roster is synthetic |
| [solutions-playbooks](https://github.com/gharvey135/solutions-playbooks) | The documents I actually use across an engagement: discovery question bank with red-flag answers, scoping worksheet, ADRs, design doc, runbook, UAT plan, handoff checklist, escalation playbook, EBR outline, LLM workflow scoping. | Markdown | 11 docs, one consistent worked example end to end |

## Go-to's: 

Most common in my workflow: Python, TypeScript, REST and webhooks, Postgres and SQLite, APIs, Vercel, Solution Design Architecture.
