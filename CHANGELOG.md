# Changelog

All notable changes to **year-of-ai.github.io** (the org root site) are
documented here. The zer0-mistakes theme keeps its own changelog upstream at
[bamr87/zer0-mistakes](https://github.com/bamr87/zer0-mistakes).

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Fixed
- **Adversarial-review fixes for illustrated growth** (confirmed with executed
  reproductions): `claude_svg_banner.py` now re-illustrates a NEW article whose
  stamp is the shared section placeholder (previously the placeholder's
  existence skipped exactly the articles the Illustrate step exists for),
  skips no-front-matter files (README/TIMELINE/INDEX) before spending a model
  call, discovers articles inside brand-new directories (`--porcelain -uall`),
  survives non-ASCII filenames, and detects `role=` accessibly-quoted;
  `generate-preview-images.sh` refuses to route `--enhance` to the local
  provider's fake-success no-op and forwards style/output flags to the claude
  rung; `grow-lineage.yml`'s loud-failure gate now consults the `is_error`
  signal (an expired OAuth token was misdiagnosed as "growth stalled"), and
  its local-SVG fallback honours the policy output dir; the date gate covers
  `.markdown` files; the lineage dashboard's Ticks button points at the hub's
  grow-lineage runs (member repos carry no workflows under the central
  model); dangling theme-repo references removed from
  `content_review.yml`/`content-reviewer.md`.

### Changed (comment noise)
- **PR review comments only speak when they have something to say**: the
  docs-warden and deterministic content-review stickies are no longer created
  on clean runs (they still flip an existing sticky to ✅ so a reported
  problem visibly resolves); the Claude content-reviewer runs **delta
  reviews** against its previous sticky (new/unresolved findings only, a
  one-line "no new findings" update otherwise) and never posts raw API/billing
  errors to the PR.

### Added
- **Illustrated growth — Claude-authored SVG preview banners** (fleet
  alignment with lifehacker.dev and the ai-world-view hub). The grow tick
  gained a deterministic **Illustrate** step (`grow-lineage.yml`): every
  new/changed article is bannered with a content-aware vector drawing that
  Claude authors via the new `scripts/claude_svg_banner.py` — a companion
  that imports the `zer0-image-generator` gem engine as a library and reuses
  its credential chain, SVG sanitizer, and front-matter writers. Art
  direction + authoring model live in `lineage/policy.yml` `preview:`
  (policy-over-workflow, like the model tiers); keyless runs degrade to the
  engine's deterministic `local` SVG; failures never block a publish. The
  hub's own pages get the same treatment via the new fleet-standard wrapper
  `scripts/generate-preview-images.sh` (resolves the `provider: auto`
  capability ladder the published engine doesn't know yet) and the
  `zer0-image-generator` gem in the `Gemfile`; `_config.yml preview_images:`
  now pins `rasterizer: none` (SVG-only) + `provider: auto`.

### Changed
- **`grow-lineage.yml` hardening back-ported from the ai-world-view hub**:
  the hub-owned-path exclusion is factored into one `HUB_OWNED_EXCLUDE_RE`
  env (was inlined twice), and a loud-failure gate now fails the run when a
  tick publishes nothing — distinguishing an auth/setup failure (all OAuth
  passes errored) from stalled growth — instead of reporting an empty tick
  GREEN.
- **Converted from a theme fork to a `remote_theme` consumer.** The repo no
  longer vendors the zer0-mistakes theme; it renders via
  `remote_theme: "bamr87/zer0-mistakes"` on the existing native GitHub Pages
  build. Deleted the entire vendored theme layer (`_layouts/`, `_includes/`,
  `_sass/`, `_plugins/`, and the theme `assets/` — ~296 MB, mostly generated
  preview images) plus the gem/Docker/test/installer toolchain, theme docs, and
  theme-CI workflows — the repo shrank from ~310 MB to ~3 MB. Verified the
  theme's `assets/css/main.css` still compiles and home/hub/search/wiki-links
  render identically under `remote_theme`.
  - `_config.yml` / `_config_dev.yml`: `remote_theme: false` → `bamr87/zer0-mistakes`;
    removed the local `gem`/`theme` keys (and the dangling `&gem` anchor);
    `README.md` excluded from the build in both configs.
  - `Gemfile`: reduced to the consumer set (`github-pages` + `jekyll-remote-theme`
    + `jekyll-include-cache` + `webrick`); `Gemfile.lock` is now generated
    locally, not committed.
  - `docker-compose.yml`: lean local-dev setup on a stock Ruby image that fetches
    the theme over the network.
  - Kept: all content (`pages/`, `index.html`, `404.html`, `favicon.ico`,
    `search.json`), the full `_data/` theme contract, `assets/data/`
    (`wiki-index.json` + notebook CSVs), the org hub tooling, the AI content
    reviewer, and the AI-chat proxy.
- **Repointed the org theme source.** `_data/hub.yml` `theme_repo` now points at
  `bamr87/zer0-mistakes`, so newly provisioned org year-sites consume the theme
  from upstream instead of from this repo.

### Added
- **Org Content Hub (federated).** A `/hub/` dashboard and home-page year grid
  that present every repo in the org, driven by the `_data/hub.yml` registry and
  the generated `_data/hub_index.yml` + `_data/navigation/hub.yml`
  (`scripts/sync-hub-metadata.rb`, daily `hub-sync` workflow).
- **Hub source-link fallback.** While a repo's Pages site is pending, the
  dashboard and home page link its sections and key pages to the GitHub source,
  auto-upgrading to the live site once Pages is enabled.

### Fixed
- **Org landing page shadowed by the theme README.** Removed the stale
  `permalink: /` from `README.md` and excluded it from the build so `/` reliably
  serves `pages/home.md`.
- **Hub listed the site itself as a content repo.** Corrected `exclude_repos` in
  `_data/hub.yml` (the fork is named `year-of-ai.github.io`, not `zer0-mistakes`);
  the dashboard now presents only the other org repos.
