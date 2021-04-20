require 'spec_helper'

describe RuboCop::Cop::Betterment::AllowlistBlocklist, :config do
  it 'rejects a method that should use allowlist' do
    inspect_source(<<-DEF)
      class MyClass
        def whitelist; end
      end
    DEF

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include(
      'Avoid usages of whitelist & blacklist, in favor of more inclusive and descriptive language',
    )
  end

  it 'rejects a class that should use allowlist' do
    inspect_source(<<-DEF)
      class Whitelist;
        def method; end
      end
    DEF

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include(
      'Avoid usages of whitelist & blacklist, in favor of more inclusive and descriptive language',
    )
  end

  it 'rejects a variable that should use allowlist' do
    inspect_source(<<-DEF)
      class MyClass;
        whitelist = 'something'
      end
    DEF

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include(
      'Avoid usages of whitelist & blacklist, in favor of more inclusive and descriptive language',
    )
  end

  it 'rejects a string that should use allowlist' do
    inspect_source(<<-DEF)
      class MyClass;
        myvar = 'whitelist'
      end
    DEF

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include(
      'Avoid usages of whitelist & blacklist, in favor of more inclusive and descriptive language',
    )
  end

  it 'rejects a method that should use blocklist' do
    inspect_source(<<-DEF)
      class MyClass
        def blacklist; end
      end
    DEF

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include(
      'Avoid usages of whitelist & blacklist, in favor of more inclusive and descriptive language',
    )
  end

  it 'rejects a class that should use blocklist' do
    inspect_source(<<-DEF)
      class Blacklist
        def method; end
      end
    DEF

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include(
      'Avoid usages of whitelist & blacklist, in favor of more inclusive and descriptive language',
    )
  end

  it 'rejects a variable that should use blocklist' do
    inspect_source(<<-DEF)
      class MyClass;
        blacklist = 'something else'
      end
    DEF

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include(
      'Avoid usages of whitelist & blacklist, in favor of more inclusive and descriptive language',
    )
  end

  it 'rejects a string that should use blocklist' do
    inspect_source(<<-DEF)
      class MyClass;
        myvar = 'blacklist'
      end
    DEF

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line)).to eq([1])
    expect(cop.offenses.first.message).to include(
      'Avoid usages of whitelist & blacklist, in favor of more inclusive and descriptive language',
    )
  end
end
