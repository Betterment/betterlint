# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      # Disallows the use of `invert_where` method in Rails.
      class InvertWhere < Base
        MSG = "Avoid using `invert_where`. For more context, check out this blog post https://dev.to/pocke/rails-7-will-introduce-invertwhere-method-but-it-s-dangerous-50m5"

        # @!method invert_where?(node)
        def_node_matcher :invert_where?, <<~PATTERN
          (send _ :invert_where)
        PATTERN

        def on_send(node)
          return unless invert_where?(node)

          add_offense(node)
        end
      end
    end
  end
end
