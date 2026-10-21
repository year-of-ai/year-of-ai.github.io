# PRD — year-of-ai.github.io

> Product requirements for [`year-of-ai/year-of-ai.github.io`](https://github.com/year-of-ai/year-of-ai.github.io).
> Derived from the README, agent docs, config and code in this repo. Anything not
> stated in those sources is marked **TBD**; success metrics are proposals.

## 1. Overview / problem

The organization root site for year-of-ai, a federated network of self-growing, year-by-year knowledge bases. It is three things: the landing page + content hub presenting every member site; the central growth engine that grows every year repo (members hold only content); and the organizational genome, the whole model abstracted so it can be replanted for a new concept.

## 2. Target users

- Readers browsing the org's member knowledge-base sites
- The maintainer operating the growth engine and self-improvement fleet
- Anyone replanting the model for a new concept (genome)

## 3. Goals and non-goals

**Goals**

- Present and link every member year site
- Grow members centrally via a Haiku → Sonnet → Opus pipeline with ≥2-source fact verification
- Keep the genome (`genome/manifest.yml`) in sync so the org can be replanted

**Non-goals**

- Vendoring theme files (theme is remote and untagged)
- Storing member content in the hub

## 4. Core features (current)

- Jekyll hub on remote `zer0-mistakes` theme; dashboards for hub and lineage
- `lineage/` seeds, policy and staged agent framework
- Workflows: orchestrate, grow-lineage, telemetry ledger, fleet health, docs-warden, content review
- Genome: manifest, schema, `genome/bin/` verify/render/plant
- `telemetry/evolution.jsonl` ledger

## 5. Requirements

**Functional**

- `genome/bin/verify.rb --check` fails on any concept-bearing file not classified in `genome/manifest.yml`
- Members self-register via `_data/hub.yml` auto-discovery

**Non-functional**

- Autonomy gated by `_data/fleet_pause.yml` and per-lane arming variables
- PR checks run even when the fleet is paused
- Production on native GitHub Pages (deploy from `main`)

## 6. Success metrics (proposed — not defined in sources)

- Member sites growing on schedule (ticks/week)
- Build success rate across member sites
- Docs-warden pass rate
- Targets: TBD

## 7. Roadmap / open questions

- Several member READMEs (2006–2011) say they were consolidated into `year-of-ai/2005-2011`, which does not resolve on GitHub — status TBD

## 8. Links

- [README.md](README.md) · [CLAUDE.md](CLAUDE.md) · [ARCHITECTURE.md](ARCHITECTURE.md) · [CHANGELOG.md](CHANGELOG.md) · [genome/GENOME.md](genome/GENOME.md)
