# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class AvoidEarlyReturn < Base
        MSG = "Avoid early returns as guard clauses. Prefer a single return path, such as a boolean expression, " \
              "`if`/`else`, `&.then`, or an extracted predicate method."
        LAST_CHILD_TAIL_TYPES = %i(begin kwbegin when in_pattern resbody and or).freeze

        def on_return(node)
          scope = node.each_ancestor(:any_def, :any_block).first
          add_offense(node) if scope&.any_def_type? && !tail_position?(node, scope)
        end

        private

        def tail_position?(node, scope)
          parent = node.parent
          parent.equal?(scope) || (tail_child?(node, parent) && tail_position?(parent, scope))
        end

        def tail_child?(child, parent)
          case parent.type
          when *LAST_CHILD_TAIL_TYPES then parent.children.last.equal?(child)
          when :if, :case, :case_match then !parent.children.first.equal?(child)
          when :rescue then !parent.children.first.equal?(child) || parent.children.last.nil?
          when :ensure then parent.children.first.equal?(child)
          else false
          end
        end
      end
    end
  end
end
