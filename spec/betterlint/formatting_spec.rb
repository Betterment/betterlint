# frozen_string_literal: true
# typed: true

require 'spec_helper'
require 'fileutils'
require 'open3'
require 'tmpdir'

describe 'Betterlint formatting' do
  context 'with shared defaults' do
    let(:config) do
      RuboCop::ConfigLoader.configuration_from_file(File.expand_path('../../config/default.yml', __dir__))
    end

    it 'rejects alignment padding where Betterlint has no explicit preference' do
      expect(config.for_cop('Layout/ExtraSpacing')['AllowForAlignment']).to be(false)
    end

    it 'preserves explicit Betterlint rules and implicit activation' do
      expect(config.for_cop('Layout/LineLength')).to include('Enabled' => true, 'Max' => 140)
      expect(config.cop_enabled?('Style/StringLiterals')).to be(false)
      expect(config.cop_enabled?('Layout/FirstParameterIndentation')).to be(false)
      expect(config.for_cop('Style/HashSyntax')).to include(
        'EnforcedStyle' => 'ruby19_no_mixed_keys',
        'EnforcedShorthandSyntax' => 'always',
      )
      expect(config.for_cop('Style/PercentLiteralDelimiters')['PreferredDelimiters']).to include('%w' => '()', '%r' => '{}')
      expect(config.for_cop('Style/TrailingCommaInArguments')['EnforcedStyleForMultiline']).to eq('comma')
    end
  end

  context 'with the formatter command' do
    let(:root) { File.expand_path('../..', __dir__) }
    let(:settings) { {} }
    let(:directory) { Dir.mktmpdir('format-spec-', File.join(root, '.scratch')) }

    around do |example|
      FileUtils.mkdir_p(File.join(root, '.scratch'))
      File.write(File.join(directory, '.rubocop.yml'), {
        'inherit_from' => File.join(root, 'config/default.yml'),
        'AllCops' => {'TargetRubyVersion' => 3.0},
      }.merge(settings).to_yaml)
      example.run
    ensure
      FileUtils.remove_entry(directory)
    end

    def format_source(source, *arguments, filename: 'sample.rb', environment: {}, targets: nil)
      path = File.join(directory, filename)
      File.write(path, source)
      output, status = Open3.capture2e(
        {'RUBOCOP_CACHE_ROOT' => File.join(root, '.scratch/rubocop-cache')}.merge(environment),
        RbConfig.ruby, "-I#{root}/lib", File.join(root, 'exe/betterlint-format'), *arguments, *(targets || [filename]),
        chdir: directory
      )
      [File.read(path), status.exitstatus, output]
    end

    it 'corrects formatting without changing ordinary quotes or applying full lint corrections' do
      source = <<~RUBY
        value  = 'value'
        unused = 1
        puts(value)
      RUBY
      expected = <<~RUBY
        value = 'value'
        unused = 1
        puts(value)
      RUBY
      formatted, status, output = format_source(source)
      expect(output).not_to include('Error')
      expect(status).to eq(0), output
      expect(formatted).to eq(expected)
      expect(format_source(formatted).first).to eq(expected)
    end

    context 'with repository overrides' do
      let(:settings) do
        {
          'Layout/ExtraSpacing' => {'Enabled' => false},
          'Layout/SpaceAroundOperators' => {'Exclude' => ['sample.rb']},
          'Style/PercentLiteralDelimiters' => {'PreferredDelimiters' => {'%w' => '[]'}},
          'Style/TrailingCommaInArrayLiteral' => {'EnforcedStyleForMultiline' => 'no_comma'},
        }
      end

      it 'honors disabled rules, exclusions, nested options and array preferences' do
        source = <<~RUBY
          values  = %w[one two]
          value=values
          list = [
            values,
            value
          ]
        RUBY
        formatted, status, output = format_source(source)
        expect(output).not_to include('Error')
        expect(status).to eq(0), output
        expect(formatted).to eq(source)
      end
    end

    context 'with unsafe autocorrection disabled' do
      let(:settings) { {'Layout/SpaceAroundOperators' => {'SafeAutoCorrect' => false}} }

      it 'reports the offense without unsafe correction' do
        formatted, status, = format_source("value=1\n")
        expect(formatted).to eq("value=1\n")
        expect(status).to eq(1)
      end
    end

    it 'checks formatting without modifying the file' do
      formatted, status, = format_source("value=1\n", '--check')
      expect(formatted).to eq("value=1\n")
      expect(status).to eq(1)
    end

    it 'preserves global exclusions even for explicit paths' do
      FileUtils.mkdir_p(File.join(directory, 'vendor'))
      formatted, status, = format_source("value=1\n", filename: 'vendor/sample.rb')
      expect(formatted).to eq("value=1\n")
      expect(status).to eq(0)
    end

    it 'rejects options that could widen correction scope' do
      formatted, status, = format_source("value=1\n", '--autocorrect-all')
      expect(formatted).to eq("value=1\n")
      expect(status).not_to eq(0)
    end

    it 'rejects environment options that could make a check modify files' do
      formatted, status, = format_source("value=1\n", '--check', environment: {'RUBOCOP_OPTS' => '--autocorrect'})
      expect(formatted).to eq("value=1\n")
      expect(status).to eq(2)
    end

    it 'rejects argument files that could make a check modify files' do
      File.write(File.join(directory, '.rubocop'), '--autocorrect')
      formatted, status, = format_source("value=1\n", '--check')
      expect(formatted).to eq("value=1\n")
      expect(status).to eq(2)
    end

    it 'honors individual global exclusions during discovery under a hidden directory' do
      FileUtils.mkdir_p(File.join(directory, 'db'))
      formatted, status, = format_source("value=1\n", filename: 'db/schema.rb', targets: [])
      expect(formatted).to eq("value=1\n")
      expect(status).to eq(0)
    end

    it 'does not load configuration from excluded dependency directories' do
      Dir.mktmpdir('dependency-', File.join(root, '.scratch')) do |dependency|
        FileUtils.mkdir_p(File.join(directory, 'vendor/gems'))
        File.write(File.join(dependency, '.rubocop.yml'), "inherit_from: missing.yml\n")
        File.write(File.join(dependency, 'example.rb'), "value=1\n")
        File.symlink(dependency, File.join(directory, 'vendor/gems/dependency'))
        formatted, status, output = format_source("value=1\n", targets: ['.'])
        expect(status).to eq(0), output
        expect(formatted).to eq("value = 1\n")
      end
    end

    it 'excludes unreviewed cops loaded from nested directory configuration' do
      FileUtils.mkdir_p(File.join(directory, 'nested'))
      File.write(File.join(directory, 'nested/.rubocop.yml'), <<~YAML)
        require:
          - ./rewrite.rb
        AllCops:
          Exclude:
            - rewrite.rb
        Style/UnreviewedRewrite:
          Enabled: true
      YAML
      File.write(File.join(directory, 'nested/rewrite.rb'), <<~RUBY)
        module RuboCop
          module Cop
            module Style
              class UnreviewedRewrite < Base
                extend AutoCorrector

                def on_send(node)
                  add_offense(node, message: 'Unreviewed rewrite') do |corrector|
                    corrector.replace(node, 'nil')
                  end
                end
              end
            end
          end
        end
      RUBY
      formatted, status, output = format_source("puts('value')\n", filename: 'nested/sample.rb', targets: ['nested'])
      expect(formatted).to eq("puts('value')\n"), output
      expect(status).to eq(0), output
    end
  end
end
