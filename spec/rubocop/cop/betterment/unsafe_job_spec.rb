describe RuboCop::Cop::Betterment::UnsafeJob, :config do
  let(:offense_unsafe_job) do
    <<~MSG.freeze
      This job takes a parameter that will end up serialized in plaintext. Do not pass sensitive data as bare arguments into jobs.

      See here for more information on this error:
      https://github.com/Betterment/betterlint#bettermentunsafejob
    MSG
  end

  context 'when creating a job that inherits from ApplicationJob' do
    it 'registers an offense when perform takes unsafe parameters' do
      cop.sensitive_params = [:password]

      inspect_source(<<~RUBY)
        class RegistrationJob < ApplicationJob
          def perform(user_id:, password: nil)
            do_something
          end
        end
      RUBY

      expect(cop.offenses.size).to be(1)
      expect(cop.offenses.map(&:line)).to eq([2])
      expect(cop.highlights.uniq).to eq(['password: nil'])
      expect(cop.messages.uniq).to eq([offense_unsafe_job])
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

      inspect_source(<<~RUBY)
        class AsyncMisc
          def perform(user_id:, password: nil)
            do_something
          end
        end
      RUBY
      cop.class_regex = temp

      expect(cop.offenses.size).to be(1)
      expect(cop.offenses.map(&:line)).to eq([2])
      expect(cop.highlights.uniq).to eq(['password: nil'])
      expect(cop.messages.uniq).to eq([offense_unsafe_job])
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
      cop.class_regex = temp
    end
  end

  context 'when creating a job that does not inherit from ApplicationJob' do
    it 'registers an offense when perform takes unsafe parameters' do
      cop.sensitive_params = [:password]

      inspect_source(<<~RUBY)
        class RegistrationJob
          def perform(user_id:, password: nil)
            do_something
          end
        end
      RUBY

      expect(cop.offenses.size).to be(1)
      expect(cop.offenses.map(&:line)).to eq([2])
      expect(cop.highlights.uniq).to eq(['password: nil'])
      expect(cop.messages.uniq).to eq([offense_unsafe_job])
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
