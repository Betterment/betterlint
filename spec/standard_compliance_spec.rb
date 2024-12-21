# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'standard compliance' do
  let(:exceptions) do
    %w(
      Layout/LineLength
      Lint/AmbiguousBlockAssociation
      Lint/AmbiguousOperator
      Lint/AmbiguousRegexpLiteral
      Lint/BooleanSymbol
      Metrics/AbcSize
      Metrics/ClassLength
      Metrics/CyclomaticComplexity
      Metrics/ModuleLength
      Metrics/ParameterLists
      Metrics/PerceivedComplexity
      Naming/PredicateName
      Naming/VariableNumber
      Style/BlockDelimiters
      Style/FrozenStringLiteralComment
      Style/LambdaCall
      Style/MissingElse
      Style/NumberedParameters
      Style/PercentLiteralDelimiters
      Style/SafeNavigation
      Style/StringLiterals
      Style/TrailingCommaInArguments
      Style/TrailingCommaInArrayLiteral
      Style/TrailingCommaInHashLiteral
      Style/YodaCondition
    )
  end

  let(:default_config) do
    root = Gem.loaded_specs['rubocop'].full_gem_path
    path = File.expand_path('config/default.yml', root)
    config = YAML.safe_load_file(path, permitted_classes: [Regexp, Symbol])
    config.delete('AllCops')
    config
  end

  let(:standard_config) do
    root = Gem.loaded_specs['standard'].full_gem_path
    path = File.expand_path('config/base.yml', root)
    YAML.safe_load_file(path)
  end

  let(:betterlint_config) do
    YAML.safe_load_file('config/default.yml')
  end

  it 'complies with standardrb with notable exceptions' do
    violations = betterlint_config.filter_map do |name, betterlint|
      default = default_config[name] or next
      standard = standard_config.fetch(name, {})

      betterlint = default.merge(betterlint)
      standard = default.merge(standard)

      name if betterlint != standard
    end

    new_violations = (violations - exceptions).sort
    old_exceptions = (exceptions - violations).sort

    expect(new_violations).to be_empty, <<~MSG
      All new rules should match Standard. These following rules are invalid:

      #{new_violations.join("\n")}
    MSG

    expect(old_exceptions).to be_empty, <<~MSG
      The following rules are now compliant with Standard and can be removed from the exceptions:

      #{old_exceptions.join("\n")}
    MSG
  end
end
