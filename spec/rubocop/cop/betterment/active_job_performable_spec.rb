require 'spec_helper'

describe RuboCop::Cop::Betterment::ActiveJobPerformable, :config do
  it 'rejects a performable that is a plain ruby class' do
    inspect_source(<<~RUBY)
      class MyJob
        def perform
          MyModel.new.save!
        end
      end
    RUBY

    expect(cop.offenses.size).to be(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include('Classes that are "performable" should be ActiveJobs')
  end

  it 'rejects a performable that does not subclass ApplicationJob' do
    inspect_source(<<~RUBY)
      class MyJob < Base::Class
        def perform
          MyModel.new.save!
        end
      end
    RUBY

    expect(cop.offenses.size).to be(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include('Classes that are "performable" should be ActiveJobs')
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
end
