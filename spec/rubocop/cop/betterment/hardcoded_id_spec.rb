require 'spec_helper'

describe RuboCop::Cop::Betterment::HardcodedID, :config do
  it "does not add an offense for valid usage" do
    expect_no_offenses(<<~RUBY)
      FactoryBot.create(:foo, idea: 42) # Starts with ID
      FactoryBot.create(:foo, liquid: 42) # Ends with ID
      FactoryBot.create(:foo, id: 'apples') # Not digits
    RUBY
  end

  it "adds an offense for a hardcoded ID" do
    expect_offense(<<~RUBY)
      FactoryBot.create(:foo, id: 42, name: 'Rick')
                              ^^^^^^ Hardcoded IDs cause flaky tests. Use a sequence instead.
    RUBY
  end

  it "adds an offense for a hardcoded string ID" do
    expect_offense(<<~RUBY)
      FactoryBot.create(:foo, id: '42', name: 'Rick')
                              ^^^^^^^^ Hardcoded IDs cause flaky tests. Use a sequence instead.
    RUBY
  end

  it "adds an offense for a hardcoded foreign key" do
    expect_offense(<<~RUBY)
      FactoryBot.create(:foo, user_id: 42, name: 'Rick')
                              ^^^^^^^^^^^ Hardcoded IDs cause flaky tests. Use a sequence instead.
    RUBY
  end

  it "adds an offense for a hardcoded ID when a trait is used" do
    expect_offense(<<~RUBY)
      FactoryBot.create(:foo, :trait, user_id: 42, name: 'Rick')
                                      ^^^^^^^^^^^ Hardcoded IDs cause flaky tests. Use a sequence instead.
    RUBY
  end

  it "adds an offense for each violating pair" do
    expect_offense(<<~RUBY)
      FactoryBot.create(:foo, id: 42, user_id: 42)
                                      ^^^^^^^^^^^ Hardcoded IDs cause flaky tests. Use a sequence instead.
                              ^^^^^^ Hardcoded IDs cause flaky tests. Use a sequence instead.
    RUBY
  end

  it "adds an offense for a hardcoded ID in create_list" do
    expect_offense(<<~RUBY)
      FactoryBot.create_list(:foo, 2, id: 42, name: 'Rick')
                                      ^^^^^^ Hardcoded IDs cause flaky tests. Use a sequence instead.
    RUBY
  end

  it "adds an offense when the ID is hardcoded in a let block" do
    expect_offense(<<~RUBY)
      RSpec.describe "blah" do
        let(:user_id) { 42 }
        ^^^^^^^^^^^^^^^^^^^^ Hardcoded IDs cause flaky tests. Use a sequence instead.
        let(:user) { FactoryBot.create(:user, user_id: user_id) }
      end
    RUBY
  end

  it "does not add an offense for a let that is not used by a factory" do
    expect_no_offenses(<<~RUBY)
      RSpec.describe "blah" do
        let(:user_id) { 42 }
        specify { expect(user_id).to eq(42) }
      end
    RUBY
  end

  it "does not add an offense for a let that is not an ID" do
    expect_no_offenses(<<~RUBY)
      RSpec.describe "blah" do
        let(:amount) { 42 }
        let(:user) { FactoryBot.build(:user, amount: amount) }
      end
    RUBY
  end

  it "attempts to correct a let containing a factory with a hardcoded ID" do
    expect_offense(<<~RUBY)
      RSpec.describe do
        let(:foo) { FactoryBot.create(:foo, id: '42', name: 'Rick') }
                                            ^^^^^^^^ Hardcoded IDs cause flaky tests. Use a sequence instead.
        specify { 42 }
        specify { 'Foo 42' }
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe do
        let(:foo) { FactoryBot.create(:foo, name: 'Rick') }
        specify { foo.id }
        specify { "Foo \#{foo.id}" }
      end
    RUBY
  end

  it "cannot correct a let containing a factory with a hardcoded reference ID" do
    expect_offense(<<~RUBY)
      RSpec.describe do
        let(:foo) { FactoryBot.create(:foo, user_id: '42', name: 'Rick') }
                                            ^^^^^^^^^^^^^ Hardcoded IDs cause flaky tests. Use a sequence instead.
        specify { 42 }
        specify { 'Foo 42' }
      end
    RUBY

    expect_no_corrections
  end

  it "cannot correct outside of a block" do
    expect_offense(<<~RUBY)
      RSpec.describe do
        let(:foo) { FactoryBot.create(:foo, id: '42', name: 'Rick') }
                                            ^^^^^^^^ Hardcoded IDs cause flaky tests. Use a sequence instead.
        include_examples "foo", url: "/foos/42"
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe do
        let(:foo) { FactoryBot.create(:foo, name: 'Rick') }
        include_examples "foo", url: "/foos/42"
      end
    RUBY
  end

  it "corrects a let containing an ID" do
    expect_offense(<<~RUBY)
      RSpec.describe do
        let(:foo_id) { 42 }
        ^^^^^^^^^^^^^^^^^^^ Hardcoded IDs cause flaky tests. Use a sequence instead.
        let(:foo) { FactoryBot.create(:foo, id: foo_id, name: 'Rick') }
        specify { foo.id }
        specify { 'Foo 42' }
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe do
        let(:foo_id) { foo.id }
        let(:foo) { FactoryBot.create(:foo, name: 'Rick') }
        specify { foo.id }
        specify { "Foo \#{foo.id}" }
      end
    RUBY
  end

  it "corrects multiple violations in a string" do
    expect_offense(<<~RUBY)
      RSpec.describe do
        let(:foo) { FactoryBot.create(:foo, id: 1) }
                                            ^^^^^ Hardcoded IDs cause flaky tests. Use a sequence instead.
        let(:bar) { FactoryBot.create(:bar, id: 2) }
                                            ^^^^^ Hardcoded IDs cause flaky tests. Use a sequence instead.
        specify { 'http://example.org/foo/1/bar/2' }
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe do
        let(:foo) { FactoryBot.create(:foo) }
        let(:bar) { FactoryBot.create(:bar) }
        specify { "http://example.org/foo/\#{foo.id}/bar/\#{bar.id}" }
      end
    RUBY
  end
end
