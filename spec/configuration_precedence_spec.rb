# frozen_string_literal: true
# typed: true

require 'spec_helper'

RSpec.describe 'Betterlint configuration precedence' do
  let(:root) { File.expand_path('..', __dir__) }
  let(:authored) { YAML.load_file(File.join(root, 'config/default.yml')) }
  let(:effective) { RuboCop::ConfigLoader.configuration_from_file(File.join(root, 'config/default.yml')) }
  let(:snapshot) { YAML.load_file(File.join(root, 'config/formatting.yml')) }

  def expect_preferences(actual, expected)
    expected.each do |key, value|
      if value.is_a?(Hash)
        expect_preferences(actual.fetch(key), value)
      elsif key == 'Exclude'
        value.each { |pattern| expect(actual.fetch(key).any? { |item| item.end_with?(pattern) }).to be(true) }
      else
        expect(actual[key]).to eq(value)
      end
    end
  end

  it 'preserves every authored option above the imported formatting defaults' do
    authored.each do |name, preferences|
      next unless preferences.is_a?(Hash) && name != 'AllCops'

      expect_preferences(effective.for_cop(name), preferences)
    end
  end

  it 'preserves default activation for explicitly configured rules' do
    snapshot.each_key do |name|
      next unless authored.key?(name) && !authored[name].key?('Enabled')

      expect(effective.for_cop(name)['Enabled']).to eq(RuboCop::ConfigLoader.default_configuration.for_cop(name)['Enabled'])
    end
  end
end
