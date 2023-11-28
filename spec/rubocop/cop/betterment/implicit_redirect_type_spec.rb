# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Betterment::ImplicitRedirectType, :config do
  let(:expected_error) do
    'Rails will create a permanent (301) redirect, which is dangerous. Please specify your desired status, e.g. redirect(..., status: 302)'
  end

  it 'registers no offenses outside of routes.rb files' do
    expect_no_offenses(<<-RUBY, 'not_routes.rb')
      get 'demo', to: redirect('/app/demo')
    RUBY
  end

  it 'registers an offense when redirecting without options' do
    expect_offense(<<-RUBY, 'routes.rb')
      get 'demo', to: redirect('/app/demo')
                      ^^^^^^^^^^^^^^^^^^^^^ #{expected_error}
    RUBY
  end

  it 'registers an offense when redirecting with a block without options' do
    expect_offense(<<-RUBY, 'routes.rb')
      get 'demo', to: redirect { |_params, _request| '/' }
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{expected_error}
    RUBY
  end

  it 'registers an offense when omitting the status parameter with path as an argument' do
    expect_offense(<<-RUBY, 'routes.rb')
      get 'demo', to: redirect('/app/demo', protocol: 'http')
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{expected_error}
    RUBY
  end

  it 'registers an offense when omitting the status parameter with a block' do
    expect_offense(<<-RUBY, 'routes.rb')
      get 'demo', to: redirect(protocol: 'http') { |_params, _request| '/' }
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{expected_error}
    RUBY
  end

  it 'registers no offenses when an explicit value is provided with path as an argument' do
    expect_no_offenses(<<-RUBY, 'routes.rb')
      get 'demo', to: redirect('/app/demo', status: 301)
    RUBY
  end

  it 'registers no offenses when an explicit value is provided with a block' do
    expect_no_offenses(<<-RUBY, 'routes.rb')
      get 'demo', to: redirect(status: 301) { |_params, _request| '/app/demo' }
    RUBY
  end
end
