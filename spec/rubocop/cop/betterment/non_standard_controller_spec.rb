# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::NonStandardController, :betterlint_config do
  it 'adds an offense when a controller is specified' do
    expect_offense(<<~RUBY)
      resources :users, controller: 'non_standard'
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^ `resources` and `resource` [...]

      resource :user, controller: 'non_standard'
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^ `resources` and `resource` [...]

      resources :users, controller: 'non_standard', only: [:index]
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^ `resources` and `resource` [...]

      resources :users, only: [:index], controller: 'non_standard'
                                        ^^^^^^^^^^^^^^^^^^^^^^^^^^ `resources` and `resource` [...]
    RUBY
  end

  it 'does not add an offense when a controller is not specified' do
    expect_no_offenses(<<~RUBY)
      resources :users
      resources :users, only: [:index]
      resource :user
      resource :user, only: [:index]
    RUBY
  end
end
