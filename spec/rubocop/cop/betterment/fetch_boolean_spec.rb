# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::FetchBoolean, :config do
  context 'when using parameters' do
    it 'registers an offense when defaulting to a boolean value' do
      expect_offense(<<~RUBY)
        class UserController < ApplicationController
          def taxable
            params.fetch(:taxable, false)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ A boolean fetched [...]
          end
        end
      RUBY
    end

    it 'registers an offense when defaulting to a boolean value in assignment from ENV' do
      expect_offense(<<~RUBY)
        class App
          def do_thing
            in_progress = ENV.fetch('IN_PROGRESS', true)
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ A boolean fetched [...]
            check_for(in_progress)
          end
        end
      RUBY
    end

    it 'registers an offense when defaulting to a boolean value in method call' do
      expect_offense(<<~RUBY)
        class UserController < ApplicationController
          def create
            do_thing(
              in_progress: create_params.permit(:in_progress, :taxable).fetch(:in_progress, false),
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ A boolean fetched [...]
            )
          end
        end
      RUBY
    end

    it 'does not register an offense when wrapped with cast' do
      expect_no_offenses(<<~RUBY)
        class UserController < ApplicationController
          def create
            ActiveModel::Type::Boolean.new.cast(params.fetch(:taxable, false))
            in_progress = ActiveModel::Type::Boolean.new.cast user_params.fetch(:in_progress, true)
            do_thing(
              in_progress: ActiveModel::Type::Boolean.new.cast(
                            create_params.permit(:in_progress, :taxable).fetch(:in_progress, false)
                          )
            )
          end
        end
      RUBY
    end

    it 'does not register an offense for params when not in a controller' do
      expect_no_offenses(<<~RUBY)
        class Application
          def create
            params.fetch(:taxable, false)
            in_progress = other.fetch('thing', true)
            do_thing(
              in_progress: create_params.permit(:in_progress, :taxable).fetch(:in_progress, false),
            )
          end
        end
      RUBY
    end
  end
end
