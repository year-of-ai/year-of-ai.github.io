# lineage/ — the canonical seeds & framework kit

This directory is the **source of truth** for the self-growing knowledge-base
lineage. It was centralized here from the individual year repos so those repos
hold only their *content* (plus a GitHub Pages `_config.yml`, `.claude/`, and
`telemetry/`); the hub owns the seed and orchestrates their growth.

- `seeds/<year>.md` — each year's **concept definition** (the `seed.md` that was
  in `year-of-ai/<year>`): subject, taxonomy, source strategy, conventions, and
  its Evolution Log. The orchestrator reads these to grow each repo.
- `seed-package/` — the **portable bootstrap kit** planted into a new repo when a
  lineage spawns: `seed.template.md`, `lifecycle.template.yml`, `MANIFEST.md`.
- `policy.yml` — the **canonical growth policy**: the 3-tier model escalation
  (Haiku → Sonnet → Opus), perpetual-growth rules, `cadence.repos_per_run`
  (stalest-first rotation — enforced by `orchestrate.yml`, ADR-0006), and auth.
- `framework/` — the **canonical agent toolkit** (`prompts/`, `skills/`,
  `agents/`) that the hub's central grow workflow stages into a cloned year
  repo to run a tick. `workflows/` and `scripts/lineage.sh` are the retired
  peer-to-peer engine, kept as reference but **excluded from staging**
  (ADR-0006) — they are unreachable under the central model.
- `decisions/` — **Architecture Decision Records** for the orchestration model.
  Start with [`ADR-0001`](decisions/ADR-0001-centralized-growth-orchestration.md)
  (why growth is centralized in the hub, and the adapter+staging mechanism).
  See also [`ADR-0006`](decisions/ADR-0006-operational-hardening-and-cadence.md)
  (the tick-hardening, the front-matter publish gate, and growth cadence).

Excluded from the Jekyll build (see `_config.yml`) — this is orchestration data,
not site content. The published lineage view is `pages/lineage.md` (`/lineage/`).
