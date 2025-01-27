# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::AuthorizationInController, :config do
  context 'when creating or updating a model' do
    it 'registers an offense for unsafe parameters' do
      expect_offense(<<~RUBY)
        class Application
          def create
            Model.new params[:user_id]
                      ^^^^^^^^^^^^^^^^ Model created/updated [...]
            Model.create! params[:user_id]
                          ^^^^^^^^^^^^^^^^ Model created/updated [...]
          end
        end
      RUBY
    end

    it 'registers an offense for unsafe parameters retrieved via static strings' do
      expect_offense(<<~RUBY)
        class Application
          def create
            Model.new params['user_id']
                      ^^^^^^^^^^^^^^^^^ Model created/updated [...]
            Model.create! params['user_id']
                          ^^^^^^^^^^^^^^^^^ Model created/updated [...]
          end
        end
      RUBY
    end

    it 'registers an offense for selecting an unsafe parameter from a variable' do
      expect_offense(<<~RUBY)
        class Application
          def create
            dangerous_parameters = params.permit(:user_id)
            Model.new dangerous_parameters[:user_id]
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            Model.create! dangerous_parameters[:user_id]
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
          end
        end
      RUBY
    end

    it 'registers an offense for variables holding unsafe parameters' do
      expect_offense(<<~RUBY)
        class Application
          def create
            dangerous_parameters = params.permit(:user_id)
            Model.new dangerous_parameters
                      ^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            Model.create! dangerous_parameters
                          ^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            @model.update dangerous_parameters
                          ^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            @model.assign_attributes dangerous_parameters
                                     ^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
          end
        end
      RUBY
    end

    it 'registers an offense for methods returning unsafe parameters via static strings' do
      expect_offense(<<~RUBY)
        class Application
          def dangerous_parameters
            params.permit('user_id')
          end

          def create
            Model.new dangerous_parameters
                      ^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            Model.create! dangerous_parameters
                          ^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            @model.update dangerous_parameters
                          ^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            @model.assign_attributes dangerous_parameters
                                     ^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
          end
        end
      RUBY
    end

    it 'registers an offense for methods returning unsafe parameters' do
      expect_offense(<<~RUBY)
        class Application
          def dangerous_parameters
            params.permit(:user_id)
          end

          def create
            Model.new dangerous_parameters
                      ^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            Model.create! dangerous_parameters
                          ^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            @model.update dangerous_parameters
                          ^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            @model.assign_attributes dangerous_parameters
                                     ^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
          end
        end
      RUBY
    end

    it 'registers an offense for methods returning unsafe parameters via kwargs' do
      expect_offense(<<~RUBY)
        class Application
          def dangerous_parameters
            params.permit(accounts: :user_id)
          end

          def create
            Model.new dangerous_parameters
                      ^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            Model.create! dangerous_parameters
                          ^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            @model.update dangerous_parameters
                          ^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            @model.assign_attributes dangerous_parameters
                                     ^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
          end
        end
      RUBY
    end

    it 'registers an offense when selecting an unsafe parameter from a method' do
      expect_offense(<<~RUBY)
        class Application
          def variety_params
            params.permit(:safe, :also_safe, :user_id)
          end

          def create
            Model.new variety_params[:user_id]
                      ^^^^^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            Model.create! variety_params[:user_id]
                          ^^^^^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            @model.update(user_id: variety_params[:user_id])
                                   ^^^^^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            @model.assign_attributes variety_params[:user_id]
                                     ^^^^^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
          end
        end
      RUBY
    end

    it 'registers an offense when a model is created or updated using a method that returns an extracted parameter' do
      expect_offense(<<~RUBY)
        class Application
          def user_id
            params[:user_id]
          end

          def create
            Model.new(user_id: user_id)
                               ^^^^^^^ Model created/updated [...]
            Model.create!(user_id: user_id)
                                   ^^^^^^^ Model created/updated [...]
            @model.update(user_id: user_id)
                                   ^^^^^^^ Model created/updated [...]
            @model.assign_attributes(user_id: user_id)
                                              ^^^^^^^ Model created/updated [...]
          end
        end
      RUBY
    end

    it 'registers an offense when passing an unsafe parameter into a keyword arg' do
      expect_offense(<<~RUBY)
        class Application
          def create_params
            params.permit(:user_id, :username)
          end

          def create
            Model.new(parameters: create_params)
                                  ^^^^^^^^^^^^^ Model created/updated [...]
            Model.create!(parameters: create_params)
                                      ^^^^^^^^^^^^^ Model created/updated [...]
          end
        end
      RUBY
    end

    it 'registers an offense when dangerous parameters are stored and used' do
      expect_offense(<<~RUBY)
        class Application
          def create_params
            params.permit(:user_id, :username)
          end

          def create
            @temporary_parameters = params[:user_id]
            Model.new(user_id: @temporary_parameters)
                               ^^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
          end
        end
      RUBY
    end

    it 'registers an offense when a method returning unsafe parameters is stored, modified, and used' do
      expect_offense(<<~RUBY)
        class Application
          def create_params
            params.permit(:user_id, :username)
          end

          def create
            @temporary_parameters = create_params.merge(key: value)
            Model.new @temporary_parameters
                      ^^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            Model.create! @temporary_parameters
                          ^^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            @model.update @temporary_parameters
                          ^^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            @model.assign_attributes @temporary_parameters
                                     ^^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]

            @some_more_params = create_params
            Model.new(parameters: @some_more_params.merge(key: value))
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
          end
        end
      RUBY
    end

    it 'registers an offense when a method returning unsafe parameters is stored and used' do
      expect_offense(<<~RUBY)
        class Application
          def create_params
            params.permit(:user_id, :username)
          end

          def create
            @temporary_parameters = create_params
            Model.new @temporary_parameters
                      ^^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            Model.create! @temporary_parameters
                          ^^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            @model.update @temporary_parameters
                          ^^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            @model.assign_attributes @temporary_parameters
                                     ^^^^^^^^^^^^^^^^^^^^^ Model created/updated [...]
          end
        end
      RUBY
    end

    it 'does not register an offense when selecting a safe parameter from a variable' do
      expect_no_offenses(<<~RUBY)
        class Application
          def a_variety_of_parameters
            params.permit(:safe, :also_safe, :user_id)
          end

          def create
            @test = a_variety_of_parameters
            Model.new @test[:safe]
            Model.create! @test[:safe]
            @model.update(safe_parameter: @test[:safe])
            @model.assign_attributes(safe_parameter: @test[:safe])
          end
        end
      RUBY
    end

    it 'does not register an offense when selecting a safe parameter from a method' do
      expect_no_offenses(<<~RUBY)
        class Application
          def a_variety_of_parameters
            params.permit(:safe, :also_safe, :user_id)
          end

          def create
            Model.new a_variety_of_parameters[:safe]
            Model.create! a_variety_of_parameters[:safe]
          end
        end
      RUBY
    end

    it 'does not register an offense when the parameters are unknown' do
      expect_no_offenses(<<~RUBY)
        class Application
          def create
            Model.new(config_params: params)
            Model.create!(config_params: params)
            @model.update(config_params: params)
            @model.assign_attributes(config_params: params)
          end
        end
      RUBY
    end

    it 'does not register an offense when a method permits and indexes using a non-symbol key' do
      expect_no_offenses(<<~RUBY)
        class Application
          def create
            Model.new(test: something_unexpected)
          end

          def something_unexpected
            params[something.unexpected]
          end
        end
      RUBY
    end

    it 'does not register an offense when a method wraps unexpected types' do
      expect_no_offenses(<<~RUBY)
        class Application
          def create_params
            if test
              params.permit(:safe, :also_safe)
            else
              :something_unexpected
            end
          end

          def create
            Model.new(create_params)
          end
        end
      RUBY
    end

    it 'does not register an offense when another method wraps an unsafe parameter' do
      expect_no_offenses(<<~RUBY)
        class Application
          def create_params
            params.permit(:safe, :also_safe, :user_id)
          end

          def create
            Model.new(current_user.users.find(create_params[:user_id]))
          end
        end
      RUBY
    end

    it 'does not register an offense when storing and using a safe parameter' do
      expect_no_offenses(<<~RUBY)
        class Application
          def create
            @safe_parameter = params[:safe_name]
            Model.new(name: @safe_parameter)
            Model.create!(name: @safe_parameter)
            @model.update(name: @safe_parameter)
            @model.assign_attributes(name: @safe_parameter)
          end
        end
      RUBY
    end

    it 'does not register an offense when extracting an unsafe parameter from an unknown source' do
      expect_no_offenses(<<~RUBY)
        class Application
          def create
            Model.new unknown_source[:user_id]
            Model.create! unknown_source[:user_id]
            @model.update unknown_source[:user_id]
            @model.assign_attributes unknown_source[:user_id]
          end
        end
      RUBY
    end

    it 'registers an offense when a method permits and indexes using an unsafe parameter' do
      expect_offense(<<~RUBY)
        class Application
          def index
            presenter = Some::Presenter.new(
              user: current_user,
              from_account_id: account_id
                               ^^^^^^^^^^ Model created/updated [...]
            )
          end

          def account_id
            params.permit(:account_id)[:account_id]
          end
        end
      RUBY
    end

    it 'does not register an offense when parameters are used safely before return' do
      expect_no_offenses(<<~RUBY)
        class Application
          def user_id
            account_id = params.permit(:user_id)
            # :user_id is used before being returned
            # normally might be a false positive
            # we're strictly checking return values
            current_user.accounts.find(account_id)
          end

          def create
            Model.new(parameters: user_id)
          end
        end
      RUBY
    end

    it 'allows unsafe parameters to be specified via config' do
      temp = cop.unsafe_parameters
      cop.unsafe_parameters = %i(dangerous shady)
      expect_offense(<<~RUBY)
        class Application
          def dangerous_param
            params.permit(:shady, :benign)
          end

          def create
            # specified via unsafe_parameters
            Model.new params[:dangerous]
                      ^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            Model.new(dangerous_param)
                      ^^^^^^^^^^^^^^^ Model created/updated [...]

            # _id should still be flagged
            Model.new params[:user_id]
                      ^^^^^^^^^^^^^^^^ Model created/updated [...]
          end
        end
      RUBY
    ensure
      cop.unsafe_parameters = temp
    end

    it 'allows the config to specify a regex alternative to _id' do
      temp = cop.unsafe_regex
      cop.unsafe_regex = /(.*_fk$|^id_.*$)/
      expect_offense(<<~RUBY)
        class Application
          def user
            params.permit(:user_fk)
          end

          def create
            # the specified parameter name matches the regex
            Model.new params[:user_fk]
                      ^^^^^^^^^^^^^^^^ Model created/updated [...]
            Model.new params[:id_number]
                      ^^^^^^^^^^^^^^^^^^ Model created/updated [...]
            Model.new(user: user)
                            ^^^^ Model created/updated [...]

            # does not match the regex any more
            Model.new params[:user_id]
          end
        end
      RUBY
    ensure
      cop.unsafe_regex = temp
    end
  end
end
