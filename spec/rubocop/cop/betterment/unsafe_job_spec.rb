# frozen_string_literal: true

describe RuboCop::Cop::Betterment::UnsafeJob, :config do
  context 'when creating a job that inherits from ApplicationJob' do
    it 'registers an offense when perform takes unsafe parameters' do
      cop.sensitive_params = [:password]

      expect_offense(<<~RUBY)
        class RegistrationJob < ApplicationJob
          def perform(user_id:, password: nil)
                                ^^^^^^^^^^^^^ This job takes a parameter [...]
            do_something
          end
        end
      RUBY
    end

    it 'does not register an offense when perform takes other parameters' do
      cop.sensitive_params = [:password]

      expect_no_offenses(<<~RUBY)
        class RegistrationJob < ApplicationJob
          def perform(user_id:)
            do_something
          end
        end
      RUBY
    end
  end

  context 'when using a non-default class regex' do
    it 'registers an offense for a job with a different naming scheme' do
      temp = cop.class_regex
      cop.class_regex = /.*Misc$/
      cop.sensitive_params = [:password]

      expect_offense(<<~RUBY)
        class AsyncMisc
          def perform(user_id:, password: nil)
                                ^^^^^^^^^^^^^ This job takes a parameter [...]
            do_something
          end
        end
      RUBY
    ensure
      cop.class_regex = temp
    end

    it 'does not register an offense that uses the default naming scheme' do
      temp = cop.class_regex
      cop.class_regex = /.*Misc$/
      cop.sensitive_params = [:password]

      expect_no_offenses(<<~RUBY)
        class DefaultJob
          def perform(user_id:, password: nil)
            do_something
          end
        end
      RUBY
    ensure
      cop.class_regex = temp
    end
  end

  context 'when creating a job that does not inherit from ApplicationJob' do
    it 'registers an offense when perform takes unsafe parameters' do
      cop.sensitive_params = [:password]

      expect_offense(<<~RUBY)
        class RegistrationJob
          def perform(user_id:, password: nil)
                                ^^^^^^^^^^^^^ This job takes a parameter [...]
            do_something
          end
        end
      RUBY
    end

    it 'does not register an offense when perform takes other parameters' do
      cop.sensitive_params = [:password]

      expect_no_offenses(<<~RUBY)
        class RegistrationJob < ApplicationJob
          def perform(user_id:)
            do_something
          end
        end
      RUBY
    end
  end

  context 'when creating a non-job class' do
    it 'does not register an offense when perform takes a sensitive parameter' do
      cop.sensitive_params = [:password]

      expect_no_offenses(<<~RUBY)
        class SomethingElse
          def perform(user_id:, password: nil)
            do_something
          end
        end
      RUBY
    end
  end
end
