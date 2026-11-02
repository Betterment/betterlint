# frozen_string_literal: true

require 'rubocop/cop/mixin/migrations_helper'
require 'rubocop/rails/migration_file_skippable'

module RuboCop
  module Cop
    module Betterment
      class NoDownMigrations < Base
        include MigrationsHelper
        prepend RuboCop::Rails::MigrationFileSkippable

        MSG = 'Do not write explicit rollback code. Correct deployed migrations with a new forward migration.'
        RESTRICT_ON_SEND = %i(down).freeze

        def on_def(node)
          add_offense(node.loc.name) if node.method?(:down) && migration_class?(node.each_ancestor(:class).first)
        end
        alias on_defs on_def

        def on_send(node)
          if migration_class?(node.each_ancestor(:class).first) && reversible_direction?(node.receiver)
            add_offense(node.loc.selector)
          end
        end
        alias on_csend on_send

        private

        def reversible_direction?(receiver)
          return false unless receiver&.lvar_type?

          binding = receiver.each_ancestor(:any_block).find do |block|
            block.argument_list.any? { |argument| argument.name == receiver.children.first }
          end

          binding&.method?(:reversible) && (binding.receiver.nil? || binding.receiver.self_type?)
        end
      end
    end
  end
end
