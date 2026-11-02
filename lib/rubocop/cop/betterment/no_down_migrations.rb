# frozen_string_literal: true

require 'rubocop/cop/mixin/migrations_helper'

module RuboCop
  module Cop
    module Betterment
      class NoDownMigrations < Base
        include MigrationsHelper

        MSG = 'Do not write explicit rollback code. Correct deployed migrations with a new forward migration.'
        RESTRICT_ON_SEND = %i(down).freeze

        def on_def(node)
          add_offense(node.loc.name) if node.method?(:down) && migration_to_check?(node)
        end
        alias on_defs on_def

        def on_send(node)
          if migration_to_check?(node) && reversible_direction?(node.receiver)
            add_offense(node.loc.selector)
          end
        end
        alias on_csend on_send

        private

        def migration_to_check?(node)
          return false unless migration_class?(node.each_ancestor(:class).first)

          cutoff = cop_config.fetch('MigratedSchemaVersion')
          version = File.basename(processed_source.file_path)[/\A\d+(?=_)/]
          !cutoff || !version || version.to_i > Integer(cutoff)
        end

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
