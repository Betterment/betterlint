# frozen_string_literal: true
# typed: true

require 'optparse'
require 'rubocop'
require 'yaml'

module Betterlint
  class Formatter
    FORMATTING_COPS = YAML.load_file(File.expand_path('../../config/formatting.yml', __dir__)).keys.freeze

    def run(arguments)
      reject_implicit_options
      paths = arguments.dup
      options = parse_options(paths)
      cli = RuboCop::CLI.new
      targets = discover_targets(cli.config_store, paths)
      return report_empty(options) if targets.empty?

      excluded = RuboCop::Cop::Registry.global.names.grep(/\A(?:Layout|Style)\//) - FORMATTING_COPS
      cli.run([
        '--only', 'Layout,Style', '--except', excluded.join(','),
        '--force-exclusion', '--safe', '--cache', 'false',
        *options, '--', *targets
      ])
    rescue OptionParser::ParseError => e
      warn e.message
      2
    end

    private

    def reject_implicit_options
      return if RuboCop::ArgumentsFile.read_as_arguments.empty? && RuboCop::ArgumentsEnv.read_as_arguments.empty?

      raise OptionParser::InvalidOption, 'use formatter options directly; .rubocop arguments and RUBOCOP_OPTS are unsupported'
    end

    def discover_targets(config_store, paths)
      root_config = config_store.for_pwd
      paths = paths.map { |path| File.expand_path(path) }
      RuboCop::TargetFinder.new(config_store, force_exclusion: true).find(paths, :all_file_types).reject do |file|
        root_config.file_to_exclude?(file) || config_store.for_file(file).file_to_exclude?(file)
      end
    end

    def report_empty(options)
      parsed, = RuboCop::Options.new.parse(options)
      formatters = RuboCop::Formatter::FormatterSet.new(parsed)
      (parsed[:formatters] || [['progress']]).each { |format| formatters.add_formatter(*format) }
      formatters.started([])
      formatters.finished([])
      0
    ensure
      formatters&.close_output_files
    end

    def parse_options(paths)
      check = false
      output = []
      OptionParser.new { |parser|
        parser.on('--check') { check = true }
        parser.on('--format FORMAT') { |format| output.push('--format', format) }
        parser.on('--out FILE') { |file| output.push('--out', file) }
      }.parse!(paths)
      output.unshift('--autocorrect') unless check
      output
    end
  end
end
