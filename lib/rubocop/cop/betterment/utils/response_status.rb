# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      module Utils
        module ResponseStatus
          extend RuboCop::NodePattern::Macros

          UNSAFE_ACTIONS = %i(create update destroy).freeze

          private

          def each_offense(node, responder_name)
            return unless UNSAFE_ACTIONS.include?(node.method_name)

            on_missing_status(node, responder_name) do |responder|
              add_offense(responder) do |corrector|
                status = yield(responder)

                if responder.arguments?
                  corrector.insert_after(responder.last_argument, ", status: #{status.inspect}")
                else
                  corrector.replace(responder, "#{responder_name} status: #{status.inspect}")
                end
              end
            end
          end

          # @!method on_missing_status(node)
          def_node_search :on_missing_status, <<~PATTERN
            {
              (send nil? %1)
              (send nil? %1 ... !(hash <(pair (sym :status) _) ...>))
            }
          PATTERN
        end
      end
    end
  end
end
