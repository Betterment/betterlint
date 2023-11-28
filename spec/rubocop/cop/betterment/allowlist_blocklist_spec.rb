# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::AllowlistBlocklist, :config do
  it 'rejects a method that should use allowlist' do
    inspect_source(<<~RUBY)
      class MyClass
        def whitelist; end
      end
    RUBY

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include(
      'Avoid usages of whitelist & blacklist, in favor of more inclusive and descriptive language',
    )
  end

  it 'rejects a class that should use allowlist' do
    inspect_source(<<~RUBY)
      class Whitelist;
        def method; end
      end
    RUBY

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include(
      'Avoid usages of whitelist & blacklist, in favor of more inclusive and descriptive language',
    )
  end

  it 'rejects a variable that should use allowlist' do
    inspect_source(<<~RUBY)
      class MyClass;
        whitelist = 'something'
      end
    RUBY

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include(
      'Avoid usages of whitelist & blacklist, in favor of more inclusive and descriptive language',
    )
  end

  it 'rejects a string that should use allowlist' do
    inspect_source(<<~RUBY)
      class MyClass;
        myvar = 'whitelist'
      end
    RUBY

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include(
      'Avoid usages of whitelist & blacklist, in favor of more inclusive and descriptive language',
    )
  end

  it 'rejects a method that should use blocklist' do
    inspect_source(<<~RUBY)
      class MyClass
        def blacklist; end
      end
    RUBY

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include(
      'Avoid usages of whitelist & blacklist, in favor of more inclusive and descriptive language',
    )
  end

  it 'rejects a class that should use blocklist' do
    inspect_source(<<~RUBY)
      class Blacklist
        def method; end
      end
    RUBY

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include(
      'Avoid usages of whitelist & blacklist, in favor of more inclusive and descriptive language',
    )
  end

  it 'rejects a variable that should use blocklist' do
    inspect_source(<<~RUBY)
      class MyClass;
        blacklist = 'something else'
      end
    RUBY

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include(
      'Avoid usages of whitelist & blacklist, in favor of more inclusive and descriptive language',
    )
  end

  it 'rejects a string that should use blocklist' do
    inspect_source(<<~RUBY)
      class MyClass;
        myvar = 'blacklist'
      end
    RUBY

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include(
      'Avoid usages of whitelist & blacklist, in favor of more inclusive and descriptive language',
    )
  end
end
