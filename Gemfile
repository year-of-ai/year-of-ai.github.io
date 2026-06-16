# =============================================================================
# Gemfile — year-of-ai.github.io (remote_theme consumer)
# =============================================================================
# This site vendors no theme files; it renders via the zer0-mistakes theme
# pulled over `remote_theme` (see _config.yml). Production builds on native
# GitHub Pages, which ignores this file and uses its own github-pages gem set —
# this Gemfile is only for local builds/previews, kept in lockstep with Pages.
# =============================================================================
source "https://rubygems.org"

# GitHub Pages gem — bundles Jekyll and every GitHub Pages whitelisted plugin
# (jekyll-seo-tag, jekyll-feed, jekyll-sitemap, jekyll-include-cache, …).
gem "github-pages", group: :jekyll_plugins

# Pull the shared theme from GitHub at build time.
gem "jekyll-remote-theme"

# Theme layouts use {% include_cached %}; load the plugin that provides it.
gem "jekyll-include-cache"

# Required to run `jekyll serve` on Ruby 3.x (webrick left the stdlib).
gem "webrick"

platforms :windows, :jruby do
  gem "tzinfo"
  gem "tzinfo-data"
end
gem "wdm", :platforms => [:windows]
