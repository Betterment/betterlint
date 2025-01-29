# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Betterment::Environment, :config do
  it 'does not allow access to the ENV' do
    expect_offense(<<~RUBY)
      ENV['RAILS_ENV']
      ^^^ Environment variables should be parsed at boot time [...]

      ENV['RAILS_ENV'] ||= 'test'
      ^^^ Environment variables should be parsed at boot time [...]

      ENV.fetch('FOO')
      ^^^ Environment variables should be parsed at boot time [...]

      ENV.fetch('FOO', nil)
      ^^^ Environment variables should be parsed at boot time [...]
    RUBY
  end
end
