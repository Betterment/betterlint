# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::ActiveJobPerformable, :config do
  it 'rejects a performable that is a plain ruby class' do
    expect_offense(<<~RUBY)
      class MyJob
            ^^^^^ Classes that are "performable" should be ActiveJobs[...]
        def perform
          MyModel.new.save!
        end
      end
    RUBY
  end

  it 'rejects a performable that does not subclass ApplicationJob' do
    expect_offense(<<~RUBY)
      class MyJob < Base::Class
            ^^^^^ Classes that are "performable" should be ActiveJobs[...]
        def perform
          MyModel.new.save!
        end
      end
    RUBY
  end

  it 'rejects a performable that has multiple methods' do
    expect_offense(<<~RUBY)
      class MyJob
            ^^^^^ Classes that are "performable" should be ActiveJobs[...]
        def foo
        end

        def perform
          MyModel.new.save!
        end

        def bar
        end
      end
    RUBY
  end

  it 'accepts a performable that subclasses ApplicationJob' do
    expect_no_offenses(<<~RUBY)
      class MyJob < ApplicationJob
        def perform
          MyModel.new.save!
        end
      end
    RUBY
  end

  it 'accepts a performable that subclasses Module::ApplicationJob' do
    expect_no_offenses(<<~RUBY)
      class MyJob < MyModule::ApplicationJob
        def perform
          MyModel.new.save!
        end
      end
    RUBY
  end

  it 'accepts a class that does not define "perform"' do
    expect_no_offenses(<<~RUBY)
      class MyModel
        def create
          Model.create! params[:user_id]
        end
      end
    RUBY
  end

  it 'accepts a class that includes a job' do
    expect_no_offenses(<<~RUBY)
      class MyBusinessLogic
        class MyJob < ApplicationJob
          def perform
            MyBusinessLogic.call
          end
        end
      end
    RUBY
  end

  it 'accepts empty classes' do
    expect_no_offenses(<<~RUBY)
      class MyClass
      end
    RUBY
  end
end
