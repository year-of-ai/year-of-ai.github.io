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

# source-literal → target-value pairs (skip blank source literals so we never
# gsub ""), longest source first so specific literals win over their substrings.
pairs = Genome::FIELD_TOKENS.values.uniq.map do |tok|
  s = src_map[tok]
  (s.nil? || s.empty?) ? nil : [s, (tgt_map[tok] || '').to_s]
end.compact.sort_by { |s, _| -s.length }

def transform(text, pairs)
  pairs.reduce(text) { |acc, (s, t)| acc.gsub(s, t) }
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
    File.write(dst, transform(body, pairs))
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
  lexicon_src.each { |w| lexicon_hits += body.scan(/\b#{Regexp.escape(w)}\b/i).size }
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
