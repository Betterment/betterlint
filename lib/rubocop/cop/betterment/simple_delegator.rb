# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class SimpleDelegator < Base
        MSG = <<~MSG
          In order to specify a set of explicitly available methods,
          use the `delegate` class method instead of `SimpleDelegator`.

          See here for more information on this error:
          https://github.com/Betterment/betterlint/#bettermentsimpledelegator
        MSG

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
