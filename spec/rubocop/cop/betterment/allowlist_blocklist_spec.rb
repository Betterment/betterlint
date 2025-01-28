# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::AllowlistBlocklist, :config do
  it 'rejects a method that should use allowlist' do
    expect_offense(<<~RUBY)
      class MyClass
      ^^^^^^^^^^^^^ Avoid usages of whitelist & blacklist[...]
        def whitelist; end
      end
    RUBY
  end

  it 'rejects a class that should use allowlist' do
    expect_offense(<<~RUBY)
      class Whitelist;
      ^^^^^^^^^^^^^^^^ Avoid usages of whitelist & blacklist[...]
        def method; end
      end
    RUBY
  end

  it 'rejects a variable that should use allowlist' do
    expect_offense(<<~RUBY)
      class MyClass;
      ^^^^^^^^^^^^^^ Avoid usages of whitelist & blacklist[...]
        whitelist = 'something'
      end
    RUBY
  end

  it 'rejects a string that should use allowlist' do
    expect_offense(<<~RUBY)
      class MyClass;
      ^^^^^^^^^^^^^^ Avoid usages of whitelist & blacklist[...]
        myvar = 'whitelist'
      end
    RUBY
  end

  it 'rejects a method that should use blocklist' do
    expect_offense(<<~RUBY)
      class MyClass
      ^^^^^^^^^^^^^ Avoid usages of whitelist & blacklist[...]
        def blacklist; end
      end
    RUBY
  end

  it 'rejects a class that should use blocklist' do
    expect_offense(<<~RUBY)
      class Blacklist
      ^^^^^^^^^^^^^^^ Avoid usages of whitelist & blacklist[...]
        def method; end
      end
    RUBY
  end

  it 'rejects a variable that should use blocklist' do
    expect_offense(<<~RUBY)
      class MyClass;
      ^^^^^^^^^^^^^^ Avoid usages of whitelist & blacklist[...]
        blacklist = 'something else'
      end
    RUBY
  end

  it 'rejects a string that should use blocklist' do
    expect_offense(<<~RUBY)
      class MyClass;
      ^^^^^^^^^^^^^^ Avoid usages of whitelist & blacklist[...]
        myvar = 'blacklist'
      end
    RUBY
  end
end
