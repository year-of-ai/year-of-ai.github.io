# CLAUDE.md

Guidance for Claude Code (claude.ai/code) working in this repository.

## What this repo is

`year-of-ai.github.io` is the **organization root site** for the `year-of-ai`
org — a landing page plus a **content hub** that presents every other repo in
the org (the year knowledge bases: 1776, 1777, 1778, the 2005–2011 lineage, …).

It is a **thin `remote_theme` consumer**, not a theme. It vendors **no** theme
files: layouts, includes, sass, compiled CSS, JS, and vendored assets all come
from [`bamr87/zer0-mistakes`](https://github.com/bamr87/zer0-mistakes) at build
time via `remote_theme` (set in `_config.yml`). Production builds on **native
GitHub Pages** ("deploy from branch": `main`, `/`), which runs only the
whitelisted plugins — there are no custom `_plugins/` here.

> If you need to change a layout, include, or stylesheet, that lives in the
> **theme repo** (`bamr87/zer0-mistakes`), not here. This repo only holds
> content, data, config, and the org hub tooling.

## Repository map

- `_config.yml` — production config. `remote_theme: "bamr87/zer0-mistakes"`.
- `_config_dev.yml` — local-dev overrides (localhost, `unpublished: true`,
  analytics off). Also uses `remote_theme`.
- `pages/` — all content collections + standalone pages (`home.md`, `hub.md`, …).
- `_data/` — data the theme reads (`navigation/`, `ui-text.yml`, `theme_skins.yml`,
  `theme_backgrounds.yml`, `authors.yml`, `landing.yml`, …) **plus** the hub:
  `hub.yml` (registry, source of truth) and the generated `hub_index.yml` +
  `navigation/hub.yml`.
- `scripts/` — hub tooling (`sync-hub-metadata.rb`, `provision-org-sites.rb`,
  `lib/hub.rb`) and the PR reviewer (`content-review.rb`).
- `templates/org-site/` — scaffold the provisioner writes into org repos.
- `templates/deploy/chat-proxy/` — Cloudflare Worker for the AI-chat widget.
- `.github/workflows/` — `hub-sync.yml`, `ai-content-review.yml`,
  `deploy-chat-proxy.yml`.
- `assets/data/` — site-owned data: `wiki-index.json` (Obsidian `[[wiki-links]]`
  index, a Liquid file built at render time) and notebook CSVs.

## Common commands

```bash
# Local preview (fetches the theme over the network — set a token to avoid limits)
export JEKYLL_GITHUB_TOKEN=$(gh auth token)
docker compose up                       # http://localhost:4000, live reload
bundle exec jekyll serve --config '_config.yml,_config_dev.yml'   # non-Docker

# Validate a build (theme is remote, so a network fetch happens)
bundle exec jekyll build --config '_config.yml,_config_dev.yml'

# Content hub
ruby scripts/sync-hub-metadata.rb            # refresh dashboard data from _data/hub.yml
ruby scripts/sync-hub-metadata.rb --check    # CI gate (no writes)
ruby scripts/provision-org-sites.rb          # scaffold/enable Pages on org repos

# Lint
yamllint -c .github/config/.yamllint.yml _config.yml _config_dev.yml _data
ruby scripts/content-review.rb --help        # the PR content reviewer
```

## Conventions

1. **Make minimal, surgical changes.** This is a content site; match existing
   front-matter and Liquid patterns in `pages/`.
2. **Don't add theme files.** No `_layouts/`, `_includes/`, `_sass/`, or
   `_plugins/` belong here — change the theme upstream and bump `remote_theme`
   (pin with `bamr87/zer0-mistakes@vX.Y.Z`) if you need a specific version.
3. **`_data/` is the theme's runtime contract.** `remote_theme` does not supply
   `_data`; the theme's layouts/includes read `site.data.*` (navigation,
   `ui-text`, skins, …). Don't delete these.
4. **Hub data is generated.** Edit `_data/hub.yml` (the registry); never hand-edit
   `_data/hub_index.yml` or `_data/navigation/hub.yml` — regenerate them.
5. **`README.md` is excluded from the build** — the homepage is `pages/home.md`.
   Keep them from colliding at `/`.
6. **Validate before declaring done.** Run a Jekyll build for any content/config
   change; run `scripts/sync-hub-metadata.rb --check` for hub changes.
