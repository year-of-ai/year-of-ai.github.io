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
  (Haiku → Sonnet → Opus), perpetual-growth rules, cadence, and auth.
- `framework/` — the **canonical agent toolkit** (`prompts/`, `skills/`,
  `agents/`, `scripts/lineage.sh`, the reference `workflows/grow.yml`) that the
  hub's central grow workflow stages into a cloned year repo to run a tick.
- `decisions/` — **Architecture Decision Records** for the orchestration model.
  Start with [`ADR-0001`](decisions/ADR-0001-centralized-growth-orchestration.md)
  (why growth is centralized in the hub, and the adapter+staging mechanism).

Excluded from the Jekyll build (see `_config.yml`) — this is orchestration data,
not site content. The published lineage view is `pages/lineage.md` (`/lineage/`).
