# frozen_string_literal: true

require 'rubocop'
require 'rubocop/cop/betterment'
require 'rubocop/rspec/support'
require 'support/betterlint_config'
require 'pry' unless ENV.fetch('CI', 'false').casecmp?('true')

RSpec.configure do |config|
  config.include RuboCop::RSpec::ExpectOffense
end
