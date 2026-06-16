# year-of-ai.github.io

The organization root site for [**year-of-ai**](https://github.com/year-of-ai) —
a federated network of self-growing, year-by-year knowledge bases (1776, 1777,
1778, the 2005–2011 lineage, …). This repo is the landing page and **content
hub** that presents and links to every site in the org.

🔗 **Live:** https://year-of-ai.github.io/

## How it works

This is a thin Jekyll site. It **vendors no theme files** — it renders with the
shared [zer0-mistakes](https://github.com/bamr87/zer0-mistakes) theme pulled in
over [`remote_theme`](https://github.com/benbalter/jekyll-remote-theme):

```yaml
# _config.yml
remote_theme: "bamr87/zer0-mistakes"   # pin a version with @vX.Y.Z
```

Production builds on **native GitHub Pages** ("deploy from branch" — `main`, `/`).
Every org year-site consumes the same theme the same way; none of them fork it.

## Layout

| Path | What it is |
|---|---|
| `_config.yml` / `_config_dev.yml` | Production / local-dev configuration |
| `pages/` | All site content (home, hub, docs, posts, notes, …) |
| `_data/` | Site data the theme reads — navigation, `ui-text`, skins, authors, plus the hub registry/dashboard data |
| `index.html`, `404.html`, `favicon.ico`, `search.json` | Site root, error page, favicon, search index |
| `assets/data/` | Site-owned data: `wiki-index.json` (Obsidian `[[wiki-links]]`), notebook CSVs |
| `scripts/` | Org **content-hub** tooling (`sync-hub-metadata.rb`, `provision-org-sites.rb`, `lib/hub.rb`) + the PR `content-review.rb` |
| `templates/org-site/` | Scaffold the provisioner writes into each org repo |
| `templates/deploy/chat-proxy/` | Cloudflare Worker proxy for the AI-chat widget |
| `.github/workflows/` | `hub-sync` (refresh dashboard), `ai-content-review` (review `pages/**` PRs), `deploy-chat-proxy` |

Everything the theme provides (`_layouts`, `_includes`, `_sass`, `assets/css`,
JS, vendored Bootstrap, images) comes from `remote_theme` at build time and is
not stored here.

## The content hub

`_data/hub.yml` is the registry of org repos. The dashboard at
[`/hub/`](https://year-of-ai.github.io/hub/) and the year grid on the home page
are generated from it:

```bash
ruby scripts/sync-hub-metadata.rb          # refresh _data/hub_index.yml + navigation/hub.yml
ruby scripts/sync-hub-metadata.rb --check  # CI gate (validate only)
ruby scripts/provision-org-sites.rb        # scaffold/enable Pages on org repos
```

The daily `hub-sync` workflow runs the sync and commits only when the org changed.

## Local development

```bash
export JEKYLL_GITHUB_TOKEN=$(gh auth token)   # avoids theme-download rate limits
docker compose up                             # http://localhost:4000 (live reload)
# or, without Docker:
bundle install && bundle exec jekyll serve --config '_config.yml,_config_dev.yml'
```

Local dev fetches the theme over the network, exactly like production. To work
against a local theme checkout instead, point `remote_theme` at a sibling clone
or use `bundle config local.jekyll-theme-zer0 ../zer0-mistakes`.

## License

[MIT](LICENSE). The zer0-mistakes theme is maintained at
[bamr87/zer0-mistakes](https://github.com/bamr87/zer0-mistakes).
