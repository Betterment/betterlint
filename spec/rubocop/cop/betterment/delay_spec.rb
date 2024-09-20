# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Betterment::Delay, :config do
  it "adds an offense when using `.delay` without arguments" do
    expect_offense(<<~RUBY)
      user.delay.save!
      ^^^^^^^^^^ Please use Active Job instead of using `Object#delay`
    RUBY
  end

  it "adds an offense when using `.delay` with arguments" do
    expect_offense(<<~RUBY)
      user.delay(foo: 'bar').save!
      ^^^^^^^^^^^^^^^^^^^^^^ Please use Active Job instead of using `Object#delay`
    RUBY
  end

  it "adds an offense when using `Delayed::Job.enqueue`" do
    expect_offense(<<~RUBY)
      Delayed::Job.enqueue(Job.new)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please use Active Job instead of using `Delayed::Job.enqueue`
    RUBY
  end
end
