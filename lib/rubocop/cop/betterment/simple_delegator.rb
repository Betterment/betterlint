# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class SimpleDelegator < Base
        MSG = "In order to specify a narrow set of explicitly available methods, " \
              "replace SimpleDelegator with direct delegation to an object."

        # @!method class_with_simple_delegator?(node)
        def_node_matcher :class_with_simple_delegator?, <<~PATTERN
          (class _ (const nil? :SimpleDelegator) _)
        PATTERN

        def on_class(node)
          add_offense(node) if class_with_simple_delegator?(node)
        end
      end
    end
  end
end
