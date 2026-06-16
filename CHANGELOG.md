# Changelog

All notable changes to **year-of-ai.github.io** (the org root site) are
documented here. The zer0-mistakes theme keeps its own changelog upstream at
[bamr87/zer0-mistakes](https://github.com/bamr87/zer0-mistakes).

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Changed
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
