# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::KwargsForFieldDefinitions, :config do
  let(:msg) { 'Use `type:` and `description:` keyword arguments [...]' }

  it 'reports a field with a positional type and description' do
    expect_offense(<<~RUBY)
      field :name, String, "The name"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
    RUBY

    expect_correction(<<~RUBY)
      field :name, type: String, description: "The name"
    RUBY
  end

  it 'reports a field with a positional list type and description' do
    expect_offense(<<~RUBY)
      field :names, [String], "The names", null: false
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
    RUBY

    expect_correction(<<~RUBY)
      field :names, type: [String], description: "The names", null: false
    RUBY
  end

  it 'autocorrects a field with a single-quoted description' do
    expect_offense(<<~RUBY)
      field :age, Integer, 'The age', null: true
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
    RUBY

    expect_correction(<<~RUBY)
      field :age, type: Integer, description: 'The age', null: true
    RUBY
  end

  it 'autocorrects a field with an interpolated description' do
    expect_offense(<<~RUBY)
      field :name, String, "The \#{kind} name"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
    RUBY

    expect_correction(<<~RUBY)
      field :name, type: String, description: "The \#{kind} name"
    RUBY
  end

  it 'autocorrects a field with a string type' do
    expect_offense(<<~RUBY)
      field :name, "String", "The \#{kind} name"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
    RUBY

    expect_correction(<<~RUBY)
      field :name, type: "String", description: "The \#{kind} name"
    RUBY
  end

  it 'autocorrects a multiline field' do
    expect_offense(<<~RUBY)
      field :name,
      ^^^^^^^^^^^^ #{msg}
        String,
        "The name",
        null: false
    RUBY

    expect_correction(<<~RUBY)
      field :name,
        type: String,
        description: "The name",
        null: false
    RUBY
  end

  it 'autocorrects a field with a namespaced type' do
    expect_offense(<<~RUBY)
      field :user, Types::UserType, "The user", null: false
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
    RUBY

    expect_correction(<<~RUBY)
      field :user, type: Types::UserType, description: "The user", null: false
    RUBY
  end

  it 'does not report a field using kwargs' do
    expect_no_offenses(<<~RUBY)
      field :name, type: String, description: "The name"
    RUBY
  end

  it 'autocorrects a field with only a positional type' do
    expect_offense(<<~RUBY)
      field :name, String, null: false
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
    RUBY

    expect_correction(<<~RUBY)
      field :name, type: String, null: false
    RUBY
  end

  it 'does not report a field that sets its type in a block' do
    expect_no_offenses(<<~RUBY)
      field :name, null: false do
        type String
      end
    RUBY
  end

  it 'does not report a resolver field' do
    expect_no_offenses(<<~RUBY)
      field :name, String, "The name", resolver: NameResolver
    RUBY
  end

  it 'does not report a mutation field' do
    expect_no_offenses(<<~RUBY)
      field :create_name, "Creates a name", mutation: CreateName
    RUBY
  end

  it 'does not report a subscription field' do
    expect_no_offenses(<<~RUBY)
      field :name_updated, String, subscription: NameUpdated
    RUBY
  end
end
