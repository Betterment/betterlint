# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::AssociationPresencePredicate, :config do
  context 'when checking whether a belongs_to record is present' do
    it 'reports and corrects present?' do
      expect_offense(<<~RUBY)
        class LegalAccount < ApplicationRecord
          belongs_to :owner

          before_validation :set_taxpayer, if: -> { owner.present? }
                                                    ^^^^^^^^^^^^^^ Use `has_owner?` instead of `owner.present?`[...]
        end
      RUBY

      expect_correction(<<~RUBY)
        class LegalAccount < ApplicationRecord
          belongs_to :owner

          before_validation :set_taxpayer, if: -> { has_owner? }
        end
      RUBY
    end

    it 'reports and corrects nil? and blank? as a negated predicate' do
      expect_offense(<<~RUBY)
        class LegalAccount < ApplicationRecord
          belongs_to :owner

          def orphaned?
            owner.nil? || self.owner.blank?
            ^^^^^^^^^^ Use `!has_owner?` instead of `owner.nil?`[...]
                          ^^^^^^^^^^^^^^^^^ Use `!has_owner?` instead of `self.owner.blank?`[...]
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class LegalAccount < ApplicationRecord
          belongs_to :owner

          def orphaned?
            !has_owner? || !has_owner?
          end
        end
      RUBY
    end

    it 'reports and corrects a negated nil? without a double negation' do
      expect_offense(<<~RUBY)
        class LegalAccount < ApplicationRecord
          belongs_to :owner

          validate :owner_is_active, if: -> { !owner.nil? }
                                              ^^^^^^^^^^^ Use `has_owner?` instead of `!owner.nil?`[...]
        end
      RUBY

      expect_correction(<<~RUBY)
        class LegalAccount < ApplicationRecord
          belongs_to :owner

          validate :owner_is_active, if: -> { has_owner? }
        end
      RUBY
    end

    it 'wraps a negated predicate that receives another call' do
      expect_offense(<<~RUBY)
        class LegalAccount < ApplicationRecord
          belongs_to :owner

          def label
            owner.nil?.to_s
            ^^^^^^^^^^ Use `!has_owner?` instead of `owner.nil?`[...]
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class LegalAccount < ApplicationRecord
          belongs_to :owner

          def label
            (!has_owner?).to_s
          end
        end
      RUBY
    end

    it 'does not report has_one associations' do
      expect_no_offenses(<<~RUBY)
        class User < ApplicationRecord
          has_one :taxpayer

          def taxpayer?
            taxpayer.present?
          end
        end
      RUBY
    end

    it 'does not report local variables or other receivers' do
      expect_no_offenses(<<~RUBY)
        class LegalAccount < ApplicationRecord
          belongs_to :owner

          def owned_by?(owner)
            owner.present? && trust.owner.present? && owner_record&.present?
          end
        end
      RUBY
    end
  end

  context 'when checking a belongs_to foreign key' do
    it 'reports predicates and presence checks on the foreign key without correcting' do
      expect_offense(<<~RUBY)
        class LegalAccount < ApplicationRecord
          belongs_to :owner

          validates :name, presence: true, if: :owner_id?
                                               ^^^^^^^^^^ Use `has_owner?` instead of checking `owner_id?`[...]

          def owned?
            owner_id? && owner_id.present?
            ^^^^^^^^^ Use `has_owner?` instead of checking `owner_id?`[...]
                         ^^^^^^^^^^^^^^^^^ Use `has_owner?` instead of checking `owner_id`[...]
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'uses a custom foreign key' do
      expect_offense(<<~RUBY)
        class LegalAccount < ApplicationRecord
          belongs_to :owner, -> { active }, class_name: 'User', foreign_key: :ownerID

          def owned?
            ownerID.nil? || owner_id?
            ^^^^^^^^^^^^ Use `has_owner?` instead of checking `ownerID`[...]
          end
        end
      RUBY
    end

    it 'does not report composite foreign keys' do
      expect_no_offenses(<<~RUBY)
        class LegalAccount < ApplicationRecord
          belongs_to :owner, foreign_key: %i(owner_id owner_region)

          def owned?
            owner_id.present?
          end
        end
      RUBY
    end
  end

  context 'when checking whether a belongs_to will change' do
    it 'reports foreign key change checks without correcting' do
      expect_offense(<<~RUBY)
        class Account < ApplicationRecord
          belongs_to :goal

          validate :goal_is_cash, if: -> { goal_id_changed? }
                                           ^^^^^^^^^^^^^^^^ Use `will_save_change_to_goal?` instead of `goal_id_changed?` before save[...]
          before_save :notify, if: [:active?, :will_save_change_to_goal_id?]
                                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `will_save_change_to_goal?` instead of `will_save_change_to_goal_id?` before save[...]
        end
      RUBY

      expect_no_corrections
    end

    it 'does not report change checks in after callbacks' do
      expect_no_offenses(<<~RUBY)
        class Account < ApplicationRecord
          belongs_to :goal

          after_commit :notify, if: :goal_id_changed?
          after_save :notify, if: -> { will_save_change_to_goal_id? }
        end
      RUBY
    end
  end

  context 'when the predicate would not be generated' do
    it 'does not report associations whose reader or predicates are defined in the class' do
      expect_no_offenses(<<~RUBY)
        class LegalAccount < ApplicationRecord
          belongs_to :owner
          belongs_to :taxpayer

          def owner
            super || default_owner
          end

          def has_taxpayer?
            true
          end

          def check
            owner.present? && taxpayer_id?
          end
        end
      RUBY
    end

    it 'does not report code outside the declaring class' do
      expect_no_offenses(<<~RUBY)
        class LegalAccount < ApplicationRecord
          belongs_to :owner

          def self.ownerless?(record)
            owner.nil?
          end

          class << self
            def owned?
              owner_id?
            end
          end

          class Builder
            def owned?
              owner.present?
            end
          end
        end

        class Report
          def owned?
            owner.present?
          end
        end
      RUBY
    end
  end
end
