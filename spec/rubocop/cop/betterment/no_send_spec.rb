# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::NoSend, :config do
  it 'reports an offense for send with a dynamic method name' do
    expect_offense(<<~RUBY)
      record.send(attribute_name)
             ^^^^ Call the method directly instead of using `send`[...]
    RUBY
  end

  it 'reports an offense for public_send with a literal method name' do
    expect_offense(<<~RUBY)
      record.public_send(:name)
             ^^^^^^^^^^^ Call the method directly instead of using `public_send`[...]
    RUBY
  end

  it 'reports an offense for __send__ without a receiver' do
    expect_offense(<<~RUBY)
      __send__(method_name, value)
      ^^^^^^^^ Call the method directly instead of using `__send__`[...]
    RUBY
  end

  it 'reports an offense for send through safe navigation' do
    expect_offense(<<~RUBY)
      record&.send(:name)
              ^^^^ Call the method directly instead of using `send`[...]
    RUBY
  end

  it 'does not report an offense for send without arguments' do
    expect_no_offenses(<<~RUBY)
      message.send
    RUBY
  end

  it 'does not report an offense for direct method calls' do
    expect_no_offenses(<<~RUBY)
      record.name
    RUBY
  end
end
