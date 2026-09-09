# Georgia Harvey

Solutions Architect and Sales Engineer, Austin TX. Seven years shipping enterprise integrations and AI workflows end to end: discovery, architecture, build, launch, and the handoff that makes them stick. I also co-own two Austin venues, which is why several repos here reconcile reservations, POS checks, and HR paperwork instead of todo lists.

Previously: AI Technical Lead and North America Solutions Architect at Productboard, Technical Account Manager for 150+ enterprise API accounts at Perigon, Implementation Lead at Melio Payments, Product Operations at Sentieo (AlphaSense).

Portfolio: [georgia-sa-portfolio.vercel.app](https://georgia-sa-portfolio.vercel.app)  ·  Email: gharvey135@gmail.com

## Start here

| Repo | What it is | Stack | Proof |
| --- | --- | --- | --- |
| [luna-integration](https://github.com/gharvey135/luna-integration) | Reservations-to-POS reconciliation for a nightclub group: TableList reservations matched to Union and Toast checks with an explainable scoring engine; table minimums, no-shows, revenue by section, deposit reconciliation. In use at my venues. | TypeScript, Node 22, SQLite, zero runtime deps | 117 offline tests, `npm run demo` runs the whole pipeline on a recorded night |
| [integration-patterns](https://github.com/gharvey135/integration-patterns) | Seven primitives every enterprise integration needs, written once with the edge cases as tests: webhook verification, idempotency keys, retry with backoff, token-bucket rate limiting, pagination, circuit breaker, transactional outbox. | TypeScript, zero runtime deps | 75 tests, each module documents the production incident it prevents |
| [api-contract-diff](https://github.com/gharvey135/api-contract-diff) | CLI that diffs two OpenAPI specs and classifies every change as breaking, warning, or info. Exits non-zero on breaking changes so it can gate a release. Built because unannounced breaking changes were my top escalation source as a TAM. | Python, one dependency | 17 breaking rules, 50 tests |
| [precisely](https://github.com/gharvey135/precisely) | Five-stage address intelligence pipeline for insurance underwriting: verification, geocoding, PreciselyID, location risk enrichment, LLM risk narratives, and a VP-facing impact summary. Take-home for a Senior SE interview, run against the live API. | Python | 466 of 500 dirty addresses confirmed with zero manual review, 53 tests |
| [hr-compliance-automation](https://github.com/gharvey135/hr-compliance-automation) | Weekly HR/TABC compliance tracker: scanned documents in Dropbox become a one-row-per-employee snapshot in Google Sheets plus expiry alerts. Production for two venues; this is the de-identified version. | Python, Google Apps Script, scheduled Claude task | 45 tests, sample roster is synthetic |
| [solutions-playbooks](https://github.com/gharvey135/solutions-playbooks) | The documents I actually use across an engagement: discovery question bank with red-flag answers, scoping worksheet, ADRs, design doc, runbook, UAT plan, handoff checklist, escalation playbook, EBR outline, LLM workflow scoping. | Markdown | 11 docs, one consistent worked example end to end |

Also here: [signifyd-slides](https://github.com/gharvey135/signifyd-slides) and [signifyd-design-system](https://github.com/gharvey135/signifyd-design-system) (brand tokens and a React slide kit built for a Signifyd SE interview), and [jane-docs](https://github.com/gharvey135/jane-docs) (a Docusaurus developer portal with a typed API wrapper example).

## How I work

Discovery before design: I ask for peak-hour volumes, dedup keys, and who owns errors before I draw a box. Every integration gets idempotent writes, classified retries, and a runbook the customer's team can run without me. AI goes in where an eval set says it helps, with a human-in-the-loop point wherever the cost of a wrong answer is high. Labels are honest: shipped means shipped, reference implementation means reference implementation.

Stack I reach for: TypeScript and Python, REST and webhooks, Postgres and SQLite, Salesforce and HubSpot APIs, Google Workspace APIs, Claude and other LLM APIs, Vercel, GitHub Actions.
