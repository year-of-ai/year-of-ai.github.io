# CLAUDE.md

Guidance for Claude Code (claude.ai/code) working in this repository.

## What this repo is

`year-of-ai.github.io` is the **organization root site** for the `year-of-ai`
org — a landing page plus a **content hub** that presents every other repo in
the org (the year knowledge bases: 1776–1778 and 2005–2012, and growing).

It is a **thin `remote_theme` consumer**, not a theme. It vendors **no** theme
files: layouts, includes, sass, compiled CSS, JS, and vendored assets all come
from [`bamr87/zer0-mistakes`](https://github.com/bamr87/zer0-mistakes) at build
time via `remote_theme` (set in `_config.yml`). Production builds on **native
GitHub Pages** ("deploy from branch": `main`, `/`), which runs only the
whitelisted plugins — there are no custom `_plugins/` here.

> If you need to change a layout, include, or stylesheet, that lives in the
> **theme repo** (`bamr87/zer0-mistakes`), not here. This repo only holds
> content, data, config, and the org hub tooling.

**[`ARCHITECTURE.md`](ARCHITECTURE.md) is the complete system reference** —
rendering pipeline, tick anatomy, fleet, genome, failure modes, runbook, and
invariants. This file is the operational quick-guide; when they disagree,
read the architecture doc and fix the drift.

## Repository map

- `_config.yml` — production config. `remote_theme` is **pinned**
  (`bamr87/zer0-mistakes@vX.Y.Z`) — all 12 org sites build on this theme, so
  bumps are deliberate: change the tag here AND `_data/hub.yml
  pages.theme_repo` together, then re-roll members with
  `provision-org-sites.rb`.
- `_config_dev.yml` — local-dev overrides (localhost, `unpublished: true`,
  analytics off). Also uses `remote_theme`.
- `pages/` — all content collections + standalone pages (`home.md`, `hub.md`, …).
- `_data/` — data the theme reads (`navigation/`, `ui-text.yml`, `theme_skins.yml`,
  `theme_backgrounds.yml`, `authors.yml`, `landing.yml`, …) **plus** the hub:
  `hub.yml` (registry, source of truth) and the generated `hub_index.yml` +
  `navigation/hub.yml`.
- `scripts/` — hub tooling (`sync-hub-metadata.rb`, `provision-org-sites.rb`,
  `lib/hub.rb`), the lineage ledger refresher (`sync-lineage-state.rb`), the
  new-era planter (`plant-lineage.rb`), the PR reviewer (`content-review.rb`),
  the docs-coverage engine (`docs-warden.rb`), the fleet-health digest
  (`fleet-health.rb`), the front-matter date normalizer
  (`normalize-front-matter-dates.rb` — the grow tick's publish gate and the
  fleet repair tool), and the **news-layout migrator**
  (`migrate-to-news-structure.rb` — one-time conversion of a flat year repo to
  the theme's `news`/`section`/`article` layout: taxonomy categories become
  `/news/<slug>/` sections, topic files become posts, and post `tags` become
  each section's sub-topics; see `--help`).
- `lineage/` — the **centralized growth source of truth** (see below):
  `seeds/<year>.md` (each year's concept + Evolution Log), `seed-package/`
  (bootstrap kit), `repo-template/` (the year-repo skeleton the planter drops),
  `policy.yml` (model tiers + cadence), `framework/` (the canonical agent toolkit
  staged into a year repo per tick), and `decisions/` (ADR-0001…0006).
  Excluded from the Jekyll build.
- `genome/` — the **abstracted org-model DNA** (ADR-0004): `genome.yml` (concept
  manifest) + `schema.json` + `manifest.yml` (transplant inventory) + `bin/`
  (`render.rb`/`plant.rb`/`verify.rb`) + `GENOME.md`. Replant the whole model in a
  new org for a new concept. Excluded from the Jekyll build.
- `telemetry/` — the hub **evolution ledger** (`evolution.jsonl`, one record per
  grow run) + its `README.md`. Excluded from the Jekyll build.
- `templates/org-site/` — scaffold the provisioner writes into org repos.
- `templates/org-profile/` — the org profile README, staged for the
  `year-of-ai/.github` repo (publish commands in its header comment).
- `templates/deploy/chat-proxy/` — Cloudflare Worker for the AI-chat widget
  (deploy secrets: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, `ANTHROPIC_API_KEY`).
  The widget is `ai_chat.enabled: false` until this proxy is actually deployed.
- `.github/workflows/` — content/site: `hub-sync.yml`, `ai-content-review.yml`,
  `deploy-chat-proxy.yml`; the **growth engine** `orchestrate.yml` (daily
  scheduler) + `grow-lineage.yml` (grows one year repo per dispatch); and the
  **self-improvement fleet** (ADR-0003) `telemetry-ledger.yml` (evolution ledger),
  `framework-pr-reviewer.yml` (gates framework PRs), `docs-warden.yml` (doc
  coverage), `pages-deploy-sentinel.yml` (member site liveness),
  `secret-expiry-watch.yml` (daily auth-credential probe), `fleet-health-watch.yml`
  (daily ledger health digest), `genome-sync.yml` (genome drift gate),
  `codeql.yml` (security scan).
- `.github/config/` — reviewer configs: `content_review.yml`, `content_rules.yml`,
  `frontmatter_schema.yml`, `environment.yml`, `docs_warden.yml` (doc-coverage map).
- `_data/fleet_pause.yml` — the global growth **kill-switch** (ADR-0003).
- `assets/data/` — site-owned data: `wiki-index.json` (Obsidian `[[wiki-links]]`
  index, a Liquid file built at render time) and notebook CSVs.

## The lineage growth engine

The hub is the **central orchestrator** for the org's self-growing knowledge
bases. The year repos (`1776`–`1778`, `2005`–`2012`) hold **only** their
content + a GitHub Pages `_config.yml` + `.claude/` + `telemetry/`. Everything
that *grows* them lives here in the hub:

- **Seeds** are centralized — `lineage/seeds/<year>.md` holds each year's concept
  (subject, taxonomy, sources, conventions) and its **Evolution Log** (§8, the
  tick clock). The year repos no longer carry a `seed.md`.
- **Policy** is centralized — `lineage/policy.yml` sets the 3-tier model
  escalation and the perpetual-growth rules. Every tick is a grow tick: repos are
  **never** consolidated, archived, or deleted; new eras spawn tangentially from
  the frontier.
- **The framework** is centralized — `lineage/framework/` is the canonical agent
  toolkit (`prompts/`, `skills/`, `agents/`, `scripts/`, a reference
  `workflows/grow.yml`) staged into a cloned year repo at tick time, then
  stripped before publish so the year repo stays clean.

How a tick runs:

1. `orchestrate.yml` (daily cron `30 5 * * *`) refreshes `_data/lineage.yml` from
   the seeds via `sync-lineage-state.rb`, then dispatches `grow-lineage.yml` for
   the **`cadence.repos_per_run` stalest members** (from `lineage/policy.yml`;
   0 = every member every day).
2. `grow-lineage.yml` first runs a **gate job** (fleet kill-switch + input
   validation), then checks out the target year repo, stages
   `lineage/framework/*` (minus the dead peer-to-peer surfaces) +
   `lineage/seeds/<repo>.md`, and runs the **3-tier escalation**
   (`claude-haiku-4-5` draft → `claude-sonnet-4-6` expand →
   `claude-opus-4-8` enhance). An **API-key fallback** pass fires if the OAuth
   passes produce no content changes or report `is_error`.
3. The updated seed §8 is persisted back to `lineage/seeds/<repo>.md`; the staged
   framework/seed are stripped, front-matter dates are normalized to ISO
   (`scripts/normalize-front-matter-dates.rb` — an unparseable `date:` fails a
   member's whole Pages build), and **only** new content + telemetry are pushed
   to the year repo.

**Auth (org secrets):** `CLAUDE_CODE_OAUTH_TOKEN` (primary model auth),
`ANTHROPIC_API_KEY` (fallback), `LIFECYCLE_PAT` (cross-repo push + workflow
dispatch). The model values come from `lineage/policy.yml`, not the workflow —
change tiers there. Use authoritative model IDs (`claude-haiku-4-5`,
`claude-sonnet-4-6`, `claude-opus-4-8`).

## Common commands

```bash
# Local preview (fetches the theme over the network — set a token to avoid limits)
export JEKYLL_GITHUB_TOKEN=$(gh auth token)
docker compose up                       # http://localhost:4000, live reload
bundle exec jekyll serve --config '_config.yml,_config_dev.yml'   # non-Docker

# Validate a build (theme is remote, so a network fetch happens)
bundle exec jekyll build --config '_config.yml,_config_dev.yml'
# Sandboxed / minimal shells: system-gem installs need BUNDLE_PATH=<scratch>/bundle,
# and SassC needs a UTF-8 locale — export LC_ALL=en_US.UTF-8

# Content hub
ruby scripts/sync-hub-metadata.rb            # refresh dashboard data from _data/hub.yml
ruby scripts/sync-hub-metadata.rb --check    # CI gate (no writes)
ruby scripts/provision-org-sites.rb          # scaffold/enable Pages on org repos

# Lineage growth engine
ruby scripts/sync-lineage-state.rb           # refresh _data/lineage.yml from lineage/seeds/*
ruby scripts/sync-lineage-state.rb --check   # CI gate (no writes)

# News-layout migration (one-time, per year repo — pilot: 2005). The enrichment
# YAML (per-section icon/description/featured + per-article tags) lives in
# lineage/news-migration/<year>.yml; author one per member before migrating.
ruby scripts/migrate-to-news-structure.rb --repo <year-repo> --enrichment lineage/news-migration/2005.yml --year 2005 --dry-run
ruby scripts/migrate-to-news-structure.rb --repo <year-repo> --enrichment lineage/news-migration/2005.yml --year 2005

# Fleet repair / metadata
ruby scripts/normalize-front-matter-dates.rb --check <dir>  # find unparseable/bad front-matter dates
ruby scripts/normalize-front-matter-dates.rb --fix <dir>    # normalize to ISO (the grow tick's publish gate)
ruby scripts/sync-member-metadata.rb                        # dry-run member GitHub metadata vs the registry
ruby scripts/sync-member-metadata.rb --apply                # push description/homepage/topics to members

# Lint
yamllint -c .github/config/.yamllint.yml _config.yml _config_dev.yml _data
ruby scripts/content-review.rb --help        # the PR content reviewer
```

## Conventions

1. **Make minimal, surgical changes.** This is a content site; match existing
   front-matter and Liquid patterns in `pages/`.
2. **Don't add theme files.** No `_layouts/`, `_includes/`, `_sass/`, or
   `_plugins/` belong here — change the theme upstream, release it, then bump
   the pinned `remote_theme` tag (in `_config.yml` AND `_data/hub.yml`
   together). Never float the theme on `HEAD`.
3. **`_data/` is the theme's runtime contract.** `remote_theme` does not supply
   `_data`; the theme's layouts/includes read `site.data.*` (navigation,
   `ui-text`, skins, …). Don't delete these.
4. **Hub data is generated.** Edit `_data/hub.yml` (the registry); never hand-edit
   `_data/hub_index.yml` or `_data/navigation/hub.yml` — regenerate them.
   Likewise `_data/lineage.yml` is generated from `lineage/seeds/*` — edit the
   seeds (and `lineage/policy.yml` for model tiers/cadence), then regenerate.
5. **Root docs are excluded from the build** (`README.md`, `ARCHITECTURE.md`,
   `CLAUDE.md`, `CHANGELOG.md`) — the homepage is `pages/home.md`; keep
   README from colliding at `/`. The exclude list is duplicated in
   `_config_dev.yml` (Jekyll replaces, not merges, `exclude:`).
6. **Front-matter `date:` values are single plain ISO dates** (`YYYY-MM-DD`) —
   never ranges, bare years, or prose. One bad date fails a member's whole
   Pages build (this took the 1777 site down for six days).
   `scripts/normalize-front-matter-dates.rb` is the gate and the repair tool.
7. **Validate before declaring done.** Run a Jekyll build for any content/config
   change; run `scripts/sync-hub-metadata.rb --check` for hub changes,
   `sync-lineage-state.rb --check` for lineage changes, and
   `ruby genome/bin/verify.rb` after adding files (every concept-bearing
   tracked file must be classified in `genome/manifest.yml`).
8. **Serialize writers (ADR-0003 repo-write-serializer).** Any new workflow/agent
   that writes a **year repo's `main`** must use `concurrency.group:
   repo-write-<repo>` (the group `grow-lineage.yml` holds), so two writers never
   race the branch. Every dispatching/mutating workflow reads
   `_data/fleet_pause.yml` first (the kill-switch) — `orchestrate`,
   `grow-lineage` (gate job), `hub-sync`, and the fleet watchers all do; keep
   that true for anything new. Hub-`main` pushers must retry with rebase (seed
   persists, the telemetry ledger, and the dashboards all commit to hub main).
   `framework-mutation` / `policy-mutation` concurrency groups are the
   *convention* for any future workflow that mutates those surfaces via PR —
   no current workflow writes them, so the groups exist only as doctrine.
