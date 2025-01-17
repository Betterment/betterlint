# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::UseGlobalStrictLoading::ForAssociations, :config do
  context 'when `strict_loading` is set in an association' do
    it 'registers an offense for belongs_to' do
      expect_offense(<<~RUBY)
        class MyModel < ApplicationRecord
          belongs_to :user, strict_loading: false # preserve this comment
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not set `:strict_loading` in ActiveRecord associations.
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyModel < ApplicationRecord
          belongs_to :user # preserve this comment
        end
      RUBY
    end

    it 'registers an offense for has_and_belongs_to_many' do
      expect_offense(<<~RUBY)
        class MyModel < ApplicationRecord
          has_and_belongs_to_many :tags, strict_loading: true # preserve this comment
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not set `:strict_loading` in ActiveRecord associations.
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyModel < ApplicationRecord
          has_and_belongs_to_many :tags # preserve this comment
        end
      RUBY
    end

    it 'registers an offense for has_many' do
      expect_offense(<<~RUBY)
        class MyModel < ApplicationRecord
          has_many :posts, strict_loading: true # preserve this comment
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not set `:strict_loading` in ActiveRecord associations.
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyModel < ApplicationRecord
          has_many :posts # preserve this comment
        end
      RUBY
    end

    it 'registers an offense for has_one' do
      expect_offense(<<~RUBY)
        class MyModel < ApplicationRecord
          has_one :account, strict_loading: true # preserve this comment
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not set `:strict_loading` in ActiveRecord associations.
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyModel < ApplicationRecord
          has_one :account # preserve this comment
        end
      RUBY
    end

    it 'preserves other options' do
      expect_offense(<<~RUBY)
        class MyModel < ApplicationRecord
          has_many :posts, strict_loading: true, dependent: :destroy # preserve this comment
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not set `:strict_loading` in ActiveRecord associations.
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyModel < ApplicationRecord
          has_many :posts, dependent: :destroy # preserve this comment
        end
      RUBY
    end

    it 'preserves multiline options' do
      expect_offense(<<~RUBY)
        class MyModel < ApplicationRecord
          has_many :posts,        # preserve this comment
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not set `:strict_loading` in ActiveRecord associations.
            strict_loading: true, # preserve this comment
            dependent: :destroy   # preserve this comment
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyModel < ApplicationRecord
          has_many :posts,        # preserve this comment, # preserve this comment
            dependent: :destroy   # preserve this comment
        end
      RUBY
    end
  end

  context 'when `strict_loading` is not set in an association' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class MyModel < ApplicationRecord
          belongs_to :user              # comment
          has_many :posts               # comment
          has_and_belongs_to_many :tags # comment
          has_one :account              # comment
        end
      RUBY
    end
  end
end
