# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::AvoidEarlyReturn, :config do
  describe '#on_return' do
    it 'reports an offense for a modifier guard clause with a value' do
      expect_offense(<<~RUBY)
        def author_name
          return 'Unknown' if author.nil?
          ^^^^^^^^^^^^^^^^ Avoid early returns and guard clauses.[...]

          author.name
        end
      RUBY
    end

    it 'reports an offense for a bare unless guard clause' do
      expect_offense(<<~RUBY)
        def check_out
          return unless available?
          ^^^^^^ Avoid early returns and guard clauses.[...]

          lend_to_patron
        end
      RUBY
    end

    it 'reports an offense for a guard clause in a singleton method' do
      expect_offense(<<~RUBY)
        def self.catalog(attributes:)
          return if attributes.empty?
          ^^^^^^ Avoid early returns and guard clauses.[...]

          new(**attributes)
        end
      RUBY
    end

    it 'reports an offense for a return inside an if branch followed by more statements' do
      expect_offense(<<~RUBY)
        def circulation_status
          if checked_out?
            log_checkout
            return :checked_out
            ^^^^^^^^^^^^^^^^^^^ Avoid early returns and guard clauses.[...]
          end

          :on_shelf
        end
      RUBY
    end

    it 'reports an offense for a return inside a case branch followed by more statements' do
      expect_offense(<<~RUBY)
        def condition_label
          case condition
          when :damaged
            return 'Damaged'
            ^^^^^^^^^^^^^^^^ Avoid early returns and guard clauses.[...]
          end

          condition.to_s.titleize
        end
      RUBY
    end

    it 'reports an offense for a return that is not the last statement of an if branch' do
      expect_offense(<<~RUBY)
        def late_fee
          if waived?
            return 0
            ^^^^^^^^ Avoid early returns and guard clauses.[...]
            log_waiver
          else
            overdue_fine
          end
        end
      RUBY
    end

    it 'reports an offense for a return inside a loop' do
      expect_offense(<<~RUBY)
        def first_available_book
          while (book = books.shift)
            return book if book.available?
            ^^^^^^^^^^^ Avoid early returns and guard clauses.[...]
          end
        end
      RUBY
    end

    it 'reports an offense for a return in a rescued body that has an else branch' do
      expect_offense(<<~RUBY)
        def find_book
          begin
            return shelved_copy if shelved_copy
            ^^^^^^^^^^^^^^^^^^^ Avoid early returns and guard clauses.[...]
          rescue StandardError
            nil
          else
            request_from_storage
          end
        end
      RUBY
    end

    it 'reports an offense for a return inside an elsif branch followed by more statements' do
      expect_offense(<<~RUBY)
        def condition_label
          if damaged?
            'Damaged'
          elsif lost?
            return 'Lost'
            ^^^^^^^^^^^^^ Avoid early returns and guard clauses.[...]
          end

          condition.to_s
        end
      RUBY
    end

    it 'reports an offense for a return inside an until loop' do
      expect_offense(<<~RUBY)
        def first_available_book
          until books.empty?
            book = books.shift
            return book if book.available?
            ^^^^^^^^^^^ Avoid early returns and guard clauses.[...]
          end
        end
      RUBY
    end

    it 'does not report an offense for a return that is the final expression' do
      expect_no_offenses(<<~RUBY)
        def fines_total
          tally_fines
          return total_fines
        end
      RUBY
    end

    it 'does not report an offense for returns in the final branches of a conditional' do
      expect_no_offenses(<<~RUBY)
        def late_fee
          if waived?
            log_waiver
            return 0
          else
            return overdue_fine
          end
        end
      RUBY
    end

    it 'does not report an offense for returns in the final branches of a case' do
      expect_no_offenses(<<~RUBY)
        def condition_label
          case condition
          when :damaged then return 'Damaged'
          else return condition.to_s
          end
        end
      RUBY
    end

    it 'does not report an offense for returns in the final branches of a pattern match' do
      expect_no_offenses(<<~RUBY)
        def condition_label
          case condition
          in :damaged then return 'Damaged'
          in _ then return condition.to_s
          end
        end
      RUBY
    end

    it 'does not report an offense for returns in a rescue clause at the end of a method' do
      expect_no_offenses(<<~RUBY)
        def find_book
          return request_from_storage
        rescue StandardError
          return nil
        end
      RUBY
    end

    it 'does not report an offense for a return in the body of a method with an ensure clause' do
      expect_no_offenses(<<~RUBY)
        def find_book
          return request_from_storage
        ensure
          release_hold
        end
      RUBY
    end

    it 'does not report an offense for a return on the right of a final boolean operator' do
      expect_no_offenses(<<~RUBY)
        def find_book
          shelved_copy || return
        end
      RUBY
    end

    it 'does not report an offense for a return inside a block' do
      expect_no_offenses(<<~RUBY)
        def first_available_book
          books.each do |book|
            return book if book.available?
          end

          nil
        end
      RUBY
    end

    it 'does not report an offense for a return inside a lambda' do
      expect_no_offenses(<<~RUBY)
        def isbn_validator
          check = ->(isbn) do
            return false if isbn.nil?

            isbn.valid?
          end

          check
        end
      RUBY
    end

    it 'does not report an offense for a return inside a numbered parameter block' do
      expect_no_offenses(<<~RUBY)
        def first_available_book
          books.each { return _1 if _1.available? }
          nil
        end
      RUBY
    end

    it 'does not report an offense for next or break in a block' do
      expect_no_offenses(<<~RUBY)
        def available_books
          books.each do |book|
            next unless book.available?
            break if book.reserved?

            collect(book)
          end
        end
      RUBY
    end

    it 'does not report an offense for a return outside a method' do
      expect_no_offenses(<<~RUBY)
        return if defined?(Rails)

        load_config
      RUBY
    end

    it 'does not report an offense for a return inside a block with an explicit parameter' do
      expect_no_offenses(<<~RUBY)
        def first_available_book
          books.each { |x| return x if x.available? }
          nil
        end
      RUBY
    end

    it 'does not report an offense for a return in a rescue clause when the method has an else branch' do
      expect_no_offenses(<<~RUBY)
        def find_book
          request_from_storage
        rescue StandardError
          return nil
        else
          shelve_copy
        end
      RUBY
    end

    it 'does not report an offense for a return in a rescue clause after a body without a return' do
      expect_no_offenses(<<~RUBY)
        def find_book
          request_from_storage
        rescue StandardError
          return nil
        end
      RUBY
    end

    it 'reports an offense for a guard clause in a method defined inside a block' do
      expect_offense(<<~RUBY)
        Class.new do
          def call
            return unless open?
            ^^^^^^ Avoid early returns and guard clauses.[...]

            lend_books
          end
        end
      RUBY
    end
  end
end
