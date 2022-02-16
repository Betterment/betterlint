module RuboCop
  module Cop
    module Betterment
      class MemoizationWithArguments < Base
        MSG = 'Memoized method `%<method>s` accepts arguments, ' \
              'which may cause it to return a stale result. ' \
              'Remove memoization or refactor to remove arguments.'.freeze

        def self.node_pattern
          memo_assign = '(or_asgn $(ivasgn _) _)'
          memoized_at_end_of_method = "(begin ... #{memo_assign})"
          instance_method =
            "(def $_ _ {#{memo_assign} #{memoized_at_end_of_method}})"
          class_method =
            "(defs self $_ _ {#{memo_assign} #{memoized_at_end_of_method}})"
          "{#{instance_method} #{class_method}}"
        end

        private_class_method :node_pattern
        def_node_matcher :memoized?, node_pattern

        def on_def(node)
          (method_name, ivar_assign) = memoized?(node)
          return if ivar_assign.nil? || node.arguments.length.zero? || method_name == :initialize

          msg = format(MSG, method: method_name)
          add_offense(node, location: ivar_assign.source_range, message: msg)
        end
        alias on_defs on_def
      end
    end
  end
end
