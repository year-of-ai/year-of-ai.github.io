#!/usr/bin/env ruby
# frozen_string_literal: true

# =============================================================================
# genome/bin/plant.rb — assemble (and, gated, plant) a new org from a manifest.
# =============================================================================
# Runs FROM the canonical hub (which holds the live files). For a target concept
# manifest it assembles a complete, rendered hub tree by reading the live repo per
# genome/manifest.yml — transplant files copied verbatim, template/override files
# transformed (this org's literals → the target's values, derived from the two
# manifests via render.rb's token map). No duplicate payload is committed; the
# live repo IS the source, so the genome never drifts from a stale copy.
#
#   --dry-run (default): assemble into ./_planted/<org>/, print a plan + a
#     leak report (residual source-concept literals = lexicon/edge cases to refine).
#     Creates NOTHING external.
#   --apply: STAGED — refuses. Creating a public org + its hub is irreversible and,
#     like spawning (ADR-0002), runs only on an explicit owner go (two-key confirm
#     + the human org-creation/secret steps in GENOME.md §3).
#
# Usage:
#   ruby genome/bin/plant.rb --target genome/genome.example.countries.yml
# =============================================================================

require 'yaml'
require 'fileutils'
require_relative 'render'

ROOT     = File.expand_path('../..', __dir__)
GENOME   = File.join(ROOT, 'genome')
MANIFEST = File.join(GENOME, 'manifest.yml')

opts = { source: File.join(GENOME, 'genome.yml'), out: nil, apply: false }
until ARGV.empty?
  case (a = ARGV.shift)
  when '--target'  then opts[:target] = ARGV.shift
  when '--source'  then opts[:source] = ARGV.shift
  when '--out'     then opts[:out] = ARGV.shift
  when '--apply'   then opts[:apply] = true
  when '--dry-run' then opts[:apply] = false
  else abort "unknown arg #{a.inspect}"
  end
end
abort 'usage: plant.rb --target <manifest.yml> [--dry-run]' unless opts[:target]

man      = YAML.load_file(MANIFEST)
source   = Genome.load_manifest(opts[:source])
target   = Genome.load_manifest(opts[:target])
src_map  = Genome.token_map(source)
tgt_map  = Genome.token_map(target)
org      = tgt_map['ORG'] or abort 'target manifest has no identity.org'
out      = opts[:out] || File.join(ROOT, '_planted', org)

# Distinctive structural literals — SAFE for bare gsub. Deliberately EXCLUDES
# prose/instance/date tokens: a bare UNIT_NOUN ("year") would corrupt Jekyll date
# config (:year, year-month-day); FIRST_MEMBER ("1776") would mangle ids;
# COPYRIGHT_YEAR/CRON/SUBJECT_SINGULAR/KNOWLEDGE_TABLE_HEADING/TAXONOMY_STRATEGY
# are instance/prose. The unit-noun is handled ONLY via curated phrases below.
SAFE_TOKENS = %w[
  ORG HUB_REPO HUB_DOMAIN GIT_AUTHOR_EMAIL THEME_REPO SITE_TITLE SITE_TAGLINE
  FOUNDER_NAME FOUNDER_EMAIL AUTHOR_BIO AUTHOR_LOCATION PREVIEW_IMAGE_STYLE
  PREVIEW_PROVIDER PREVIEW_MODEL CHAT_ASSISTANT_NAME CHAT_SYSTEM_PROMPT
  GOOGLE_ANALYTICS POSTHOG_API_KEY POSTHOG_HOST TWITTER INSTAGRAM YOUTUBE_URL
  GISCUS_REPO_ID GISCUS_CATEGORY_ID UNIT_ICON
].freeze

def cap_first(s)
  s.empty? ? s : s[0].upcase + s[1..-1]
end

# structural pairs (skip blank source literals so we never gsub "")
struct_pairs = SAFE_TOKENS.map do |tok|
  s = src_map[tok]
  (s.nil? || s.empty?) ? nil : [s, (tgt_map[tok] || '').to_s]
end.compact

# curated unit-prose phrases: instantiate {unit}/{units} for source + target,
# add a Title-first variant, EXACT strings only (never bare "year").
su  = src_map['UNIT_NOUN']; sus = src_map['UNIT_NOUN_PLURAL'] || (su && "#{su}s")
tu  = tgt_map['UNIT_NOUN']; tus = tgt_map['UNIT_NOUN_PLURAL'] || (tu && "#{tu}s")
phrase_pairs = (man['phrase_tokens'] || []).flat_map do |tmpl|
  next [] unless su && tu

  s = tmpl.gsub('{units}', sus.to_s).gsub('{unit}', su)
  t = tmpl.gsub('{units}', tus.to_s).gsub('{unit}', tu)
  [[s, t], [cap_first(s), cap_first(t)]]
end

# longest source first so specific literals win over their substrings.
pairs = (struct_pairs + phrase_pairs).sort_by { |s, _| -s.length }

def transform(text, pairs)
  pairs.reduce(text) { |acc, (s, t)| acc.gsub(s, t) }
end

# Drop a manual `repos:` override block (instance member data) — a planted org
# self-registers its members via auto_discover. Backs up over the block's comment.
def prune_repos(body)
  lines = body.lines
  i = lines.index { |l| l.start_with?('repos:') }
  return body unless i

  j = i
  j -= 1 while j.positive? && lines[j - 1].lstrip.start_with?('#')
  lines[0...j].join.rstrip + "\n\n# Members self-register via auto_discover; no manual repos list is transplanted.\n"
end

def expand(root, entry)
  if entry.include?('*')
    Dir.glob(File.join(root, entry), File::FNM_PATHNAME).select { |f| File.file?(f) }
  else
    p = File.join(root, entry)
    File.file?(p) ? [p] : []
  end
end

FileUtils.rm_rf(out)
copied = 0
rendered = 0
(man['transplant'] || []).each do |e|
  expand(ROOT, e).each do |src|
    rel = src.sub("#{ROOT}/", '')
    dst = File.join(out, rel)
    FileUtils.mkdir_p(File.dirname(dst))
    FileUtils.cp(src, dst)
    copied += 1
  end
end
((man['template'] || []) + (man['override'] || [])).each do |e|
  expand(ROOT, e).each do |src|
    rel = src.sub("#{ROOT}/", '')
    dst = File.join(out, rel)
    FileUtils.mkdir_p(File.dirname(dst))
    body = File.read(src, encoding: 'utf-8', invalid: :replace, undef: :replace)
    body = transform(body, pairs)
    body = prune_repos(body) if rel == '_data/hub.yml'
    File.write(dst, body)
    rendered += 1
  end
end

# Leak report: residual SOURCE-concept literals in the assembled tree (excludes
# the regenerate tier, which a genesis agent re-authors for the new concept).
STRONG = ['year-of-ai', 'Year of AI', 'Amr Abdel-Motaleb', 'amr.abdel@gmail.com'].freeze
lexicon_src = [src_map['UNIT_NOUN'], src_map['UNIT_NOUN_PLURAL']].compact.reject(&:empty?)
strong_hits = Hash.new(0)
lexicon_hits = 0
Dir.glob(File.join(out, '**', '*'), File::FNM_DOTMATCH).select { |f| File.file?(f) }.each do |f|
  body = File.read(f, encoding: 'utf-8', invalid: :replace, undef: :replace) rescue next
  STRONG.each { |lit| strong_hits[lit] += body.scan(lit).size }
  # Exclude legitimately-preserved Jekyll date placeholders (:year, year-month-day)
  # so the count reflects real concept-prose residue, not correct date config.
  prose = body.gsub('year-month-day', '').gsub(/:year\b/, '')
  lexicon_src.each { |w| lexicon_hits += prose.scan(/\b#{Regexp.escape(w)}\b/i).size }
end

puts '── plant (dry-run) ──────────────────────────────────────────'
puts "  source concept : #{src_map['SITE_TITLE']}  (org #{src_map['ORG']})"
puts "  target concept : #{tgt_map['SITE_TITLE']}  (org #{org})"
puts "  assembled tree : #{out.sub("#{ROOT}/", '')}/   (#{copied} transplanted, #{rendered} rendered)"
regen = (man['regenerate'] || [])
puts "  regenerate     : #{regen.size} narrative path(s) a genesis agent authors for the new concept:"
regen.each { |r| puts "      - #{r}" }
puts '  ── leak report ──'
strong = strong_hits.select { |_, n| n.positive? }
if strong.empty?
  puts '    ✓ no residual structural source literals (org/title/founder/email).'
else
  puts '    ✗ residual STRONG source literals (the transform missed these):'
  strong.each { |lit, n| puts "        #{lit.inspect}: #{n}" }
end
puts "    · lexicon residue ('#{lexicon_src.join("'/'")}', case-insensitive, mostly in workflow comments/descriptions): #{lexicon_hits}"
puts "      (narrative pages are in the regenerate tier; remaining hits are config/workflow prose — refine via curated phrase tokens.)"

if opts[:apply]
  warn "\n  --apply is STAGED: creating the public org #{org}/ + its hub is irreversible and"
  warn '  requires an explicit owner go (two-key confirm) plus the human org-creation +'
  warn '  secret-setting steps in GENOME.md §3. Dry-run assembled the tree above for review.'
  exit 2
end
puts "\n  DRY RUN — nothing external created. Review #{out.sub("#{ROOT}/", '')}/ then proceed per GENOME.md §3."
