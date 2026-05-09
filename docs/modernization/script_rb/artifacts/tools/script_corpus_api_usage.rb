#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'optparse'
require 'pathname'

DEFAULT_ROOT = Pathname.new(__dir__).join('../../../..').realpath
DEFAULT_INVENTORY = DEFAULT_ROOT.join('results_codex/architecture/script_rb/raw/script-corpus-file-inventory.csv')
DEFAULT_OUTPUT = DEFAULT_ROOT.join('results_codex/architecture/script_rb/raw/script-corpus-api-usage.csv')

PATTERNS = [
  {
    category: 'script_class',
    pattern: /\bScript\.(?:current|self|start|run|running\?|running|hidden|list|index|pause|unpause|kill|paused\?|exists\?|version|at_exit|clear_exit_procs|exit!|log|db|open_file|new_downstream_xml|new_downstream|new_upstream|new_script_output|namescript_incoming|trust|distrust|list_trusted)\b/
  },
  {
    category: 'script_class_other',
    pattern: /\bScript\.[A-Za-z_][A-Za-z0-9_!?=]*/
  },
  {
    category: 'exec_script',
    pattern: /\bExecScript\.(?:start|new)\b/
  },
  {
    category: 'global_lifecycle',
    pattern: /\b(?:start_script|start_scripts|start_scripts_if_available|force_start_script|stop_script|pause_script|unpause_script|hide_script|running\?|start_exec_script|before_dying|undo_before_dying|abort!)\b/
  },
  {
    category: 'global_flow',
    pattern: /\b(?:clear|match|matchtimeout|matchbefore|matchafter|matchboth|matchwait|waitforre|waitfor|wait|get\?|get|reget|regetall|pause|quiet_exit)\b/
  },
  {
    category: 'global_io',
    pattern: /\b(?:put|fput|multifput|respond|echo|send_scripts|send_to_script|unique_send_to_script|upstream_get|upstream_get\?|upstream_waitfor|unique_get|unique_get\?|unique_waitfor|toggle_unique|toggle_upstream)\b/
  },
  {
    category: 'global_movement',
    pattern: /\b(?:move|multimove|up|down|out|walk)\b/
  },
  {
    category: 'settings',
    pattern: /\b(?:Settings|CharSettings|GameSettings|InstanceSettings)\s*(?:\[|\.|::)/
  },
  {
    category: 'vars',
    pattern: /\b(?:Vars|UserVars)\s*(?:\[|\.|::)/
  },
  {
    category: 'spell',
    pattern: /\bSpell\.(?:load|\[\]|active|active\?|list|upmsgs|dnmsgs|lock_cast|unlock_cast|after_stance|after_stance=|[A-Za-z_][A-Za-z0-9_!?=]*)\b/
  },
  {
    category: 'hooks_watchfor',
    pattern: /\b(?:DownstreamHook|UpstreamHook)\.(?:add|remove|run|list|sources|hook_sources)\b|\bWatchfor(?:\.new)?\b|\bwatchfor\b/
  },
  {
    category: 'script_buffers_state',
    pattern: /\bScript\.current\.(?:vars|downstream_buffer|upstream_buffer|unique_buffer|want_downstream|want_downstream_xml|want_upstream|want_script_output|hidden|paused|silent|no_pause_all|no_kill_all|no_echo|die_with|watchfor|thread_group|labels|current_label|jump_label)\b/
  },
  {
    category: 'reflection_eval',
    pattern: /\b(?:eval|instance_eval|module_eval|class_eval|binding\.eval|send|public_send|StringProc\.new)\b/
  },
  {
    category: 'storage_direct',
    pattern: /\b(?:SQLite3::Database\.new|Sequel\.sqlite|File\.(?:open|read|write|binread)|Zlib::GzipReader\.open)\b/
  }
].freeze

options = {
  root: DEFAULT_ROOT,
  inventory: DEFAULT_INVENTORY,
  output: DEFAULT_OUTPUT
}

OptionParser.new do |parser|
  parser.banner = 'Usage: ruby script_corpus_api_usage.rb [options]'

  parser.on('--root PATH', 'Workspace root containing stage/ and results_codex/') do |value|
    options[:root] = Pathname.new(value).expand_path
  end

  parser.on('--inventory PATH', 'Input inventory CSV') do |value|
    options[:inventory] = Pathname.new(value).expand_path
  end

  parser.on('--output PATH', 'Output usage CSV') do |value|
    options[:output] = Pathname.new(value).expand_path
  end
end.parse!

def read_text(path)
  File.read(path, mode: 'r:BOM|UTF-8').scrub
rescue ArgumentError, Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError
  File.binread(path).force_encoding('UTF-8').scrub
end

def line_number_for_offset(text, offset)
  text[0...offset].count("\n") + 1
end

def token_for(match)
  match.to_s.gsub(/\s+/, '')
end

root = options.fetch(:root)
inventory_path = options.fetch(:inventory)
output_path = options.fetch(:output)
output_path.dirname.mkpath

inventory = CSV.read(inventory_path, headers: true)
rows = []

inventory.each do |file_row|
  path = root.join(file_row.fetch('path'))
  next unless path.file?

  text = read_text(path)

  PATTERNS.each do |entry|
    counts = Hash.new { |hash, key| hash[key] = { count: 0, first_line: nil } }

    text.to_enum(:scan, entry.fetch(:pattern)).each do
      match = Regexp.last_match
      token = token_for(match[0])
      counts[token][:count] += 1
      counts[token][:first_line] ||= line_number_for_offset(text, match.begin(0))
    end

    counts.each do |token, data|
      rows << {
        repo: file_row.fetch('repo'),
        support_tier: file_row.fetch('support_tier'),
        path: file_row.fetch('path'),
        repo_relative_path: file_row.fetch('repo_relative_path'),
        latest_date_signal: file_row['latest_date_signal'],
        category: entry.fetch(:category),
        token: token,
        count: data.fetch(:count),
        first_line: data.fetch(:first_line)
      }
    end
  end
end

CSV.open(output_path, 'w', write_headers: true, headers: rows.first&.keys || []) do |csv|
  rows.each { |row| csv << row }
end

puts "wrote #{rows.length} API usage rows to #{output_path}"
rows.group_by { |row| row[:repo] }.each do |repo, repo_rows|
  puts "#{repo}: #{repo_rows.length}"
end
