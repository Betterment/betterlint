# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::ResolverFieldType, :config do
  it 'registers an offense for a positional type on a field with a resolver' do
    expect_offense(<<~RUBY)
      field :full_name, String, resolver: Resolvers::FullName
                        ^^^^^^ Declare the type[...]
    RUBY
  end

  it 'registers an offense for a list type on a field with a resolver' do
    expect_offense(<<~RUBY)
      field :names, [String], "The names", resolver: Resolvers::Names
                    ^^^^^^^^ Declare the type[...]
    RUBY
  end

  it 'registers an offense for a type keyword on a field with a resolver' do
    expect_offense(<<~RUBY)
      field :full_name, type: String, resolver: Resolvers::FullName
                        ^^^^^^^^^^^^ Declare the type[...]
    RUBY
  end

  it 'registers an offense for a type on a field with a mutation' do
    expect_offense(<<~RUBY)
      field :create_user, Types::UserPayload, mutation: Mutations::CreateUser
                          ^^^^^^^^^^^^^^^^^^ Declare the type[...]
    RUBY
  end

  it 'registers an offense for a type on a field with a subscription' do
    expect_offense(<<~RUBY)
      field :user_updated, type: Types::User, subscription: Subscriptions::UserUpdated
                           ^^^^^^^^^^^^^^^^^ Declare the type[...]
    RUBY
  end

  it 'registers an offense on a multi-line field with a block' do
    expect_offense(<<~RUBY)
      field :full_name,
            String,
            ^^^^^^ Declare the type[...]
            resolver: Resolvers::FullName do
        argument :format, String, required: false
      end
    RUBY
  end

  it 'does not register an offense for a field with only a resolver' do
    expect_no_offenses(<<~RUBY)
      field :full_name, resolver: Resolvers::FullName, description: "The user's name"
    RUBY
  end

  it 'does not register an offense for a positional description on a field with a resolver' do
    expect_no_offenses(<<~RUBY)
      field :full_name, "The user's name", resolver: Resolvers::FullName
    RUBY
  end

  it 'registers an offense for a string type followed by a description on a field with a resolver' do
    expect_offense(<<~RUBY)
      field :full_name, "String", "The user's name", resolver: Resolvers::FullName
                        ^^^^^^^^ Declare the type[...]
    RUBY
  end

  it 'registers an offense for a string type on a field with a subscription' do
    expect_offense(<<~RUBY)
      field :user_updated, "Types::User", subscription: Subscriptions::UserUpdated
                           ^^^^^^^^^^^^^ Declare the type[...]
    RUBY
  end

  it 'does not register an offense for a typed field without a resolver' do
    expect_no_offenses(<<~RUBY)
      field :full_name, String, null: false
    RUBY
  end

  it 'does not register an offense for a field called on a receiver' do
    expect_no_offenses(<<~RUBY)
      form.field :full_name, String, resolver: Resolvers::FullName
    RUBY
  end
end
