#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'digest'
require 'find'
require 'optparse'
require 'pathname'
require 'time'

SCRIPT_EXTENSIONS = %w[.lic .rb .cmd .wiz].freeze

REPOSITORIES = [
  {
    key: 'scripts',
    path: 'stage/scripts',
    support_tier: 'primary',
    description: 'elanthia-online/scripts'
  },
  {
    key: 'dr-scripts',
    path: 'stage/dr-scripts',
    support_tier: 'primary',
    description: 'elanthia-online/dr-scripts'
  },
  {
    key: 'lich_repo_mirror',
    path: 'stage/lich_repo_mirror',
    support_tier: 'legacy-risk',
    description: 'FarFigNewGut/lich_repo_mirror'
  }
].freeze

DEFAULT_ROOT = Pathname.new(__dir__).join('../../../..').realpath
DEFAULT_OUTPUT = DEFAULT_ROOT.join('results_codex/architecture/script_rb/raw/script-corpus-file-inventory.csv')

options = {
  root: DEFAULT_ROOT,
  output: DEFAULT_OUTPUT
}

OptionParser.new do |parser|
  parser.banner = 'Usage: ruby script_corpus_inventory.rb [options]'

  parser.on('--root PATH', 'Workspace root containing stage/ and results_codex/') do |value|
    options[:root] = Pathname.new(value).expand_path
  end

  parser.on('--output PATH', 'CSV output path') do |value|
    options[:output] = Pathname.new(value).expand_path
  end
end.parse!

def script_file?(path)
  SCRIPT_EXTENSIONS.include?(File.extname(path).downcase)
end

def each_script_file(root)
  Find.find(root.to_s) do |path|
    if File.directory?(path)
      basename = File.basename(path)
      Find.prune if basename == '.git'
      next
    end

    yield Pathname.new(path) if script_file?(path)
  end
end

def count_lines(path)
  count = 0
  File.foreach(path) { count += 1 }
  count
rescue ArgumentError, Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError
  File.binread(path).count("\n")
end

def header_date_signals(path, max_lines: 80)
  signals = []
  line_count = 0

  File.foreach(path) do |line|
    line_count += 1
    break if line_count > max_lines

    signals.concat(line.scan(/\b(?:19|20)\d{2}[-\/.](?:0?[1-9]|1[0-2])[-\/.](?:0?[1-9]|[12]\d|3[01])\b/))
    signals.concat(line.scan(/\b(?:0?[1-9]|1[0-2])[-\/.](?:0?[1-9]|[12]\d|3[01])[-\/.](?:19|20)\d{2}\b/))
  end

  signals.uniq.first(5)
rescue ArgumentError, Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError
  []
end

def encoding_info(path)
  bytes = File.binread(path)
  text = bytes.dup.force_encoding('UTF-8')
  return { valid_utf8: true, issue: '', invalid_byte_samples: '' } if text.valid_encoding?

  samples = []
  text.scrub do |invalid|
    samples << invalid.bytes.map { |byte| format('%02X', byte) }.join(' ')
    ''
  end

  {
    valid_utf8: false,
    issue: 'invalid_utf8',
    invalid_byte_samples: samples.uniq.first(5).join('|')
  }
end

def parse_date_signal(signal)
  case signal
  when /\A((?:19|20)\d{2})[-\/.]([0-1]?\d)[-\/.]([0-3]?\d)\z/
    Time.utc(Regexp.last_match(1).to_i, Regexp.last_match(2).to_i, Regexp.last_match(3).to_i).to_date
  when /\A([0-1]?\d)[-\/.]([0-3]?\d)[-\/.]((?:19|20)\d{2})\z/
    Time.utc(Regexp.last_match(3).to_i, Regexp.last_match(1).to_i, Regexp.last_match(2).to_i).to_date
  end
rescue ArgumentError
  nil
end

def latest_date_signal(signals)
  signals
    .filter_map { |signal| parse_date_signal(signal) }
    .max
    &.iso8601
end

def file_row(workspace_root, repo, path)
  stat = File.stat(path)
  relative_to_workspace = path.relative_path_from(workspace_root).to_s
  repo_root = workspace_root.join(repo.fetch(:path))
  date_signals = header_date_signals(path)
  encoding = encoding_info(path)

  {
    repo: repo.fetch(:key),
    support_tier: repo.fetch(:support_tier),
    repo_description: repo.fetch(:description),
    path: relative_to_workspace,
    repo_relative_path: path.relative_path_from(repo_root).to_s,
    extension: File.extname(path).downcase.delete_prefix('.'),
    bytes: stat.size,
    lines: count_lines(path),
    mtime_utc: stat.mtime.utc.iso8601,
    date_signals: date_signals.join('|'),
    latest_date_signal: latest_date_signal(date_signals),
    encoding_valid_utf8: encoding.fetch(:valid_utf8),
    encoding_issue: encoding.fetch(:issue),
    invalid_utf8_byte_samples: encoding.fetch(:invalid_byte_samples),
    sha256: Digest::SHA256.file(path).hexdigest
  }
end

workspace_root = options.fetch(:root)
output_path = options.fetch(:output)
output_path.dirname.mkpath

rows = []

REPOSITORIES.each do |repo|
  repo_root = workspace_root.join(repo.fetch(:path))
  unless repo_root.directory?
    warn "missing repository path: #{repo_root}"
    next
  end

  each_script_file(repo_root) do |path|
    rows << file_row(workspace_root, repo, path)
  end
end

CSV.open(output_path, 'w', write_headers: true, headers: rows.first&.keys || []) do |csv|
  rows.each { |row| csv << row }
end

counts = rows.group_by { |row| row[:repo] }.transform_values(&:count)
puts "wrote #{rows.length} script file rows to #{output_path}"
REPOSITORIES.each do |repo|
  puts "#{repo.fetch(:key)}: #{counts.fetch(repo.fetch(:key), 0)}"
end
