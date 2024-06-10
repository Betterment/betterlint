# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class NotUsingRswag < Base
        MSG = 'API tests should use documented using rswag and not the built in `get`, `post`, `put`, `patch`, `delete` methods'

        # @!method test?(node)
        def_node_matcher :test?, <<-PATTERN
          (block (send nil? :it _) ...)
        PATTERN

        # @!method shared_method?(node)
        def_node_matcher :shared_method?, <<-PATTERN
          (def ...)
        PATTERN

        # @!method before_block?(node)
        def_node_matcher :before_block?, <<-PATTERN
          (block (send nil? :before) ...)
        PATTERN

        RESTRICT_ON_SEND = %i(get put patch post delete).freeze

        def on_send(node)
          return unless node.ancestors.any? { |a| test?(a) || shared_method?(a) || before_block?(a) }

          add_offense(node)
        end
      end
    end
  end
end
