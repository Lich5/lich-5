#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"
require "set"

ROOT = File.expand_path("../../../..", __dir__)
BASE = File.join(ROOT, "results_codex", "architecture", "script_rb")
USAGE_CSV = File.join(BASE, "raw", "script-corpus-api-usage.csv")
TOKEN_MATRIX_CSV = File.join(BASE, "raw", "script-api-token-tier-matrix.csv")
FIXTURE_CANDIDATES_CSV = File.join(BASE, "raw", "script-fixture-candidates.csv")
FIXTURE_CANDIDATES_MD = File.join(BASE, "summaries", "script-fixture-candidates.md")

PRESERVE_GLOBAL_IO = %w[
  echo respond put fput get wait waitfor waitforre match matchwait clear pause
  reget regetall matchtimeout matchbefore matchafter matchboth
].freeze

PRESERVE_LIFECYCLE = %w[
  start_script force_start_script stop_script pause_script unpause_script
  before_dying undo_before_dying start_exec_script start_scripts
  start_scripts_if_available hide_script
].freeze

PRESERVE_SCRIPT_CLASS = %w[
  Script.current Script.run Script.start Script.running? Script.exists?
  Script.kill Script.pause Script.unpause Script.paused? Script.at_exit
  Script.exit!
].freeze

COMPAT_SCRIPT_CLASS = %w[
  Script.self Script.running Script.hidden Script.list Script.index Script.log
  Script.db Script.open_file Script.trust Script.distrust Script.list_trusted
].freeze

WARN_SCRIPT_STATE = %w[
  Script.current.vars Script.current.want_downstream
  Script.current.want_downstream_xml Script.current.want_upstream
  Script.current.want_script_output Script.current.silent
  Script.current.hidden Script.current.jump_label
  Script.current.downstream_buffer
].freeze

WARN_RUNTIME_PLUMBING = %w[
  Script.new_downstream Script.new_downstream_xml Script.new_upstream
  Script.new_script_output Script.namescript_incoming Script.clear_exit_procs
].freeze

PRESERVE_HOOKS = %w[
  DownstreamHook.add DownstreamHook.remove DownstreamHook.list
  UpstreamHook.add UpstreamHook.remove UpstreamHook.list
  watchfor Watchfor.new Watchfor
].freeze

PRIVATE_HOOKS = %w[
  DownstreamHook.run UpstreamHook.run DownstreamHook.hook_sources
  UpstreamHook.hook_sources
].freeze

PRESERVE_SPELL = %w[
  Spell.active Spell.list Spell.load Spell.lock_cast Spell.unlock_cast
  Spell.upmsgs Spell.dnmsgs Spell.after_stance
].freeze

REFLECTION_TOKENS = %w[
  eval instance_eval class_eval module_eval send public_send StringProc.new
  class_variable_get
].freeze

STORAGE_TOKENS = %w[
  File.open File.read File.write File.binread SQLite3::Database.new
  Sequel.sqlite Zlib::GzipReader.open
].freeze

MOVEMENT_TOKENS = %w[move multimove up down out walk].freeze

FIXTURE_FOCUS = {
  "script_identity_lifecycle" => %w[
    Script.current Script.run Script.start Script.kill Script.running?
    Script.exists? start_script stop_script before_dying undo_before_dying
  ],
  "global_io_flow" => %w[
    echo respond put fput get wait waitfor waitforre match matchwait clear pause
  ],
  "settings_vars_identity" => [
    "Settings[", "Settings.", "CharSettings[", "CharSettings.",
    "GameSettings[", "GameSettings.", "Vars[", "Vars.",
    "UserVars[", "UserVars."
  ],
  "hooks_watchfor" => %w[
    DownstreamHook.add DownstreamHook.remove UpstreamHook.add
    UpstreamHook.remove watchfor Watchfor.new
  ],
  "legacy_script_state" => WARN_SCRIPT_STATE,
  "storage_capability" => STORAGE_TOKENS,
  "reflection_box_policy" => REFLECTION_TOKENS
}.freeze

def classify(category, token)
  if PRESERVE_GLOBAL_IO.include?(token)
    ["Preserve", "Console/game IO capability", "High-use public script IO and flow helper."]
  elsif PRESERVE_LIFECYCLE.include?(token)
    ["Preserve", "Script manager capability", "Public lifecycle helper observed across scripts."]
  elsif PRESERVE_SCRIPT_CLASS.include?(token)
    ["Preserve", "Script manager / current-script capability", "Core public Script control surface."]
  elsif COMPAT_SCRIPT_CLASS.include?(token)
    ["Compat", "Legacy Script facade", "Keep working, then review before blessing as future API."]
  elsif WARN_SCRIPT_STATE.include?(token)
    ["Warn / Deprecate", "Current-script state facade", "Preserve legacy behavior while routing mutation through runtime services."]
  elsif WARN_RUNTIME_PLUMBING.include?(token)
    ["Warn / Deprecate", "Internal runtime adapter", "Looks like script.rb plumbing; keep compatibility until instrumentation proves safe."]
  elsif PRESERVE_HOOKS.include?(token)
    ["Preserve", "Hook/event capability", "Public hook registration or watchfor API."]
  elsif PRIVATE_HOOKS.include?(token)
    ["Unsupported / Private", "Internal event dispatcher", "Runtime execution/introspection detail, not a public contract by default."]
  elsif PRESERVE_SPELL.include?(token)
    ["Preserve", "Spell/domain service capability", "Script-facing Spell API with direct corpus use."]
  elsif REFLECTION_TOKENS.include?(token)
    ["Unsupported / Private for Box strict mode", "Permissioned or denied reflection capability", "Legacy Ruby may allow it, but Box isolation should not expose private-core reach-through by default."]
  elsif STORAGE_TOKENS.include?(token)
    ["Compat in legacy; constrained in Box", "Storage capability", "Too common to break in legacy mode; future isolated mode should declare storage boundaries."]
  elsif MOVEMENT_TOKENS.include?(token)
    ["Preserve", "Command/game IO capability", "Movement helpers are legacy script ergonomics from global_defs.rb."]
  elsif category == "settings" || category == "vars"
    ["Preserve", "Settings capability scoped by script/character/game identity", "Broad script-facing persistence surface."]
  elsif category == "spell"
    ["Compat", "Spell/domain service capability", "Spell token needs manual review before final tiering."]
  elsif category == "exec_script"
    ["Compat", "Legacy exec-script facade", "Low-use but compatibility-sensitive execution path."]
  elsif category == "script_class" || category == "script_class_other"
    ["Compat", "Legacy Script facade", "Observed Script method not yet individually classified."]
  else
    ["Compat", "Legacy compatibility shim", "Observed corpus use; requires manual review before narrowing."]
  end
end

def focus_for(category, token)
  FIXTURE_FOCUS.each do |focus, tokens|
    return focus if tokens.include?(token)
  end

  case category
  when "global_movement" then "global_io_flow"
  when "spell" then "spell_domain"
  when "exec_script" then "script_identity_lifecycle"
  else "manual_review"
  end
end

rows = CSV.read(USAGE_CSV, headers: true).map(&:to_h)

script_class_seen = rows.each_with_object(Set.new) do |row, seen|
  next unless row.fetch("category") == "script_class"

  seen << [row.fetch("repo"), row.fetch("path"), row.fetch("token")]
end

rows = rows.reject do |row|
  row.fetch("category") == "script_class_other" &&
    script_class_seen.include?([row.fetch("repo"), row.fetch("path"), row.fetch("token")])
end

aggregate = {}
rows.each do |row|
  key = [row.fetch("category"), row.fetch("token")]
  entry = aggregate[key] ||= {
    "category" => row.fetch("category"),
    "token" => row.fetch("token"),
    "calls" => 0,
    "files" => Set.new,
    "primary_files" => Set.new,
    "legacy_files" => Set.new,
    "repos" => Hash.new(0)
  }

  count = row.fetch("count").to_i
  entry["calls"] += count
  entry["files"] << row.fetch("path")
  entry["repos"][row.fetch("repo")] += count
  if row.fetch("support_tier") == "primary"
    entry["primary_files"] << row.fetch("path")
  else
    entry["legacy_files"] << row.fetch("path")
  end
end

matrix_rows = aggregate.values.map do |entry|
  tier, box_direction, rationale = classify(entry["category"], entry["token"])
  {
    "category" => entry["category"],
    "token" => entry["token"],
    "initial_tier" => tier,
    "ruby_box_direction" => box_direction,
    "rationale" => rationale,
    "total_calls" => entry["calls"],
    "file_count" => entry["files"].length,
    "primary_file_count" => entry["primary_files"].length,
    "legacy_file_count" => entry["legacy_files"].length,
    "repo_call_counts" => entry["repos"].sort.map { |repo, calls| "#{repo}:#{calls}" }.join(";"),
    "fixture_focus" => focus_for(entry["category"], entry["token"])
  }
end.sort_by { |row| [-row.fetch("total_calls"), row.fetch("category"), row.fetch("token")] }

FileUtils.mkdir_p(File.dirname(TOKEN_MATRIX_CSV))
CSV.open(TOKEN_MATRIX_CSV, "w") do |csv|
  csv << matrix_rows.first.keys
  matrix_rows.each { |row| csv << row.values }
end

candidate_rows = []
FIXTURE_FOCUS.each do |focus, tokens|
  tokens.each do |token|
    matching = rows.select { |row| row.fetch("token") == token }
    next if matching.empty?

    classified = classify(matching.first.fetch("category"), token)
    matching.sort_by! do |row|
      [
        row.fetch("support_tier") == "primary" ? 0 : 1,
        row.fetch("path").include?("/spec/") ? 1 : 0,
        row.fetch("path").include?("/scripts/") || row.fetch("path").end_with?(".lic") ? 0 : 1,
        -row.fetch("count").to_i,
        row.fetch("repo"),
        row.fetch("repo_relative_path")
      ]
    end

    matching.uniq { |row| [row.fetch("repo"), row.fetch("path"), token] }.first(3).each do |row|
      candidate_rows << {
        "focus" => focus,
        "category" => row.fetch("category"),
        "token" => token,
        "initial_tier" => classified[0],
        "repo" => row.fetch("repo"),
        "support_tier" => row.fetch("support_tier"),
        "path" => row.fetch("path"),
        "repo_relative_path" => row.fetch("repo_relative_path"),
        "count" => row.fetch("count"),
        "first_line" => row.fetch("first_line"),
        "reason" => classified[2]
      }
    end
  end
end

CSV.open(FIXTURE_CANDIDATES_CSV, "w") do |csv|
  csv << candidate_rows.first.keys
  candidate_rows.each { |row| csv << row.values }
end

def md_table(rows, columns)
  lines = []
  lines << "| #{columns.join(" | ")} |"
  lines << "| #{columns.map { "---" }.join(" | ")} |"
  rows.each do |row|
    lines << "| #{columns.map { |column| row.fetch(column).to_s.gsub("|", "\\|") }.join(" | ")} |"
  end
  lines.join("\n")
end

summary_rows = FIXTURE_FOCUS.keys.map do |focus|
  subset = candidate_rows.select { |row| row.fetch("focus") == focus }
  {
    "focus" => focus,
    "tokens_with_candidates" => subset.map { |row| row.fetch("token") }.uniq.length,
    "primary_candidates" => subset.count { |row| row.fetch("support_tier") == "primary" },
    "legacy_candidates" => subset.count { |row| row.fetch("support_tier") != "primary" }
  }
end

example_rows = candidate_rows
  .select { |row| row.fetch("support_tier") == "primary" }
  .group_by { |row| row.fetch("focus") }
  .flat_map { |_focus, group| group.first(6) }

File.write(
  FIXTURE_CANDIDATES_MD,
  <<~MARKDOWN
    # script.rb Fixture Candidate List

    Status: draft, local-only.

    This list identifies representative scripts for compatibility canaries. It
    is generated from `raw/script-corpus-api-usage.csv` and prefers primary
    repositories before legacy mirror examples.

    ## Focus Summary

    #{md_table(summary_rows, %w[focus tokens_with_candidates primary_candidates legacy_candidates])}

    ## Primary Candidate Examples

    #{md_table(example_rows, %w[focus token initial_tier repo path count first_line])}

    ## Use

    Start with synthetic minimized fixtures for exact contracts, then use these
    corpus candidates as canaries. Mirror-only candidates should inform legacy
    risk, not define new architecture by themselves.

    Full candidate data is available in
    `raw/script-fixture-candidates.csv`.
  MARKDOWN
)

puts "wrote #{TOKEN_MATRIX_CSV}"
puts "wrote #{FIXTURE_CANDIDATES_CSV}"
puts "wrote #{FIXTURE_CANDIDATES_MD}"
