# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Betterment::NoDownMigrations, :betterlint_config do
  describe '#on_def' do
    it 'reports down methods in migrations' do
      expect_offense(<<~RUBY)
        class AddNickname < ActiveRecord::Migration[8.0]
          def down
              ^^^^ Do not write explicit rollback code. Correct deployed migrations with a new forward migration.
            remove_column :users, :nickname
          end
        end
      RUBY
    end

    it 'reports singleton down methods in migrations' do
      expect_offense(<<~RUBY)
        class AddNickname < ActiveRecord::Migration[8.0]
          def self.down
                   ^^^^ Do not write explicit rollback code. Correct deployed migrations with a new forward migration.
            remove_column :users, :nickname
          end
        end
      RUBY
    end

    it 'allows change and standalone up methods' do
      expect_no_offenses(<<~RUBY)
        class AddNickname < ActiveRecord::Migration[8.0]
          def change
            add_column :users, :nickname, :string
          end
        end

        class RefreshBalances < ActiveRecord::Migration[8.0]
          def up
            execute 'REFRESH MATERIALIZED VIEW balances'
          end
        end
      RUBY
    end

    it 'allows unrelated down methods outside migrations' do
      expect_no_offenses(<<~RUBY)
        def down
          move(-1)
        end

        class Elevator
          def down
            move(-1)
          end
        end
      RUBY
    end

    it 'allows down methods on helper classes nested in migrations' do
      expect_no_offenses(<<~RUBY)
        class AddNickname < ActiveRecord::Migration[8.0]
          class Elevator
            def down
              move(-1)
            end
          end
        end
      RUBY
    end

    context 'when a migrated schema version is configured' do
      let(:cop_config) { { 'MigratedSchemaVersion' => '20261030120000' } }

      it 'ignores migrations before the cutoff' do
        expect_no_offenses(<<~RUBY, 'db/migrate/20261030115959_add_nickname.rb')
          class AddNickname < ActiveRecord::Migration[8.0]
            def down
              remove_column :users, :nickname
            end
          end
        RUBY
      end

      it 'ignores migrations at the cutoff' do
        expect_no_offenses(<<~RUBY, 'db/migrate/20261030120000_add_nickname.rb')
          class AddNickname < ActiveRecord::Migration[8.0]
            def down
              remove_column :users, :nickname
            end
          end
        RUBY
      end

      it 'reports migrations after the cutoff' do
        expect_offense(<<~RUBY, 'db/migrate/20261030120001_add_nickname.rb')
          class AddNickname < ActiveRecord::Migration[8.0]
            def down
                ^^^^ Do not write explicit rollback code. Correct deployed migrations with a new forward migration.
              remove_column :users, :nickname
            end
          end
        RUBY
      end
    end
  end

  describe '#on_send' do
    it 'reports down branches using the reversible block argument' do
      expect_offense(<<~RUBY)
        class AddNickname < ActiveRecord::Migration[8.0]
          def change
            reversible do |direction|
              direction.up { add_column :users, :nickname, :string }
              direction.down { remove_column :users, :nickname }
                        ^^^^ Do not write explicit rollback code. Correct deployed migrations with a new forward migration.
            end
          end
        end
      RUBY
    end

    it 'reports down branches using numbered block arguments' do
      expect_offense(<<~RUBY)
        class AddNickname < ActiveRecord::Migration[8.0]
          def change
            reversible { _1.down { remove_column :users, :nickname } }
                            ^^^^ Do not write explicit rollback code. Correct deployed migrations with a new forward migration.
          end
        end
      RUBY
    end

    it 'reports down branches when reversible has an explicit self receiver' do
      expect_offense(<<~RUBY)
        class AddNickname < ActiveRecord::Migration[8.0]
          def change
            self.reversible do |direction|
              direction.down { remove_column :users, :nickname }
                        ^^^^ Do not write explicit rollback code. Correct deployed migrations with a new forward migration.
            end
          end
        end
      RUBY
    end

    it 'allows forward branches and unrelated down calls' do
      expect_no_offenses(<<~RUBY)
        class AddNickname < ActiveRecord::Migration[8.0]
          def change
            report = progress_report
            reversible do |direction|
              direction.up { add_column :users, :nickname, :string }
              report.down
            end
          end
        end
      RUBY
    end

    it 'allows down calls when a nested block shadows the reversible argument' do
      expect_no_offenses(<<~RUBY)
        class AddNickname < ActiveRecord::Migration[8.0]
          def change
            reversible do |direction|
              elevators.each do |direction|
                direction.down
              end
            end
          end
        end
      RUBY
    end

    it 'allows down calls in a reversible block on an unrelated receiver' do
      expect_no_offenses(<<~RUBY)
        class AddNickname < ActiveRecord::Migration[8.0]
          def change
            elevator.reversible do |direction|
              direction.down
            end
          end
        end
      RUBY
    end

    it 'allows reversible blocks outside migrations' do
      expect_no_offenses(<<~RUBY)
        class Elevator
          def move
            reversible do |direction|
              direction.down
            end
          end
        end
      RUBY
    end

    context 'when a migrated schema version is configured' do
      let(:cop_config) { { 'MigratedSchemaVersion' => '20261030120000' } }

      it 'ignores down branches in migrations at the cutoff' do
        expect_no_offenses(<<~RUBY, 'db/migrate/20261030120000_add_nickname.rb')
          class AddNickname < ActiveRecord::Migration[8.0]
            def change
              reversible do |direction|
                direction.down { remove_column :users, :nickname }
              end
            end
          end
        RUBY
      end
    end
  end
end
