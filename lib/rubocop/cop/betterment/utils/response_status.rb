# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      module Utils
        module ResponseStatus
          extend RuboCop::NodePattern::Macros

          UNSAFE_ACTIONS = %i(create update destroy).freeze

          private

          def each_offense(node, responder_name, &block)
            if UNSAFE_ACTIONS.include?(node.method_name)
              on_missing_status(node, responder_name, &block)
            end
          end

          # @!method on_missing_status(node)
          def_node_search :on_missing_status, <<~PATTERN
            (send nil? %1 ... !(hash <(pair (sym :status) _) ...>))
          PATTERN
        end
      end
    end
  end
end
