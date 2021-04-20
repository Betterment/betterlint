require 'rubocop'
require 'rubocop/cop/betterment'
require 'rubocop/rspec/support'
require 'pry'

RSpec.configure do |config|
  config.include RuboCop::RSpec::ExpectOffense
end
