# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class StatusCode < Base
        extend AutoCorrector

        ACTIONS = %i(create update destroy).freeze

        REDIRECT_MSG = <<~MSG.gsub(/\s+/, " ")
          Did you forget to specify an HTTP status code? The default is `status: :found`, which
          is usually inappropriate in this situation. Use `status: :see_other` when redirecting a
          POST, PUT, PATCH, or DELETE request to a GET resource.
        MSG

        RENDER_MSG = <<~MSG.gsub(/\s+/, " ")
          Did you forget to specify an HTTP status code? The default is `status: :ok`, which might
          be inappropriate in this situation. Rendering after a POST, PUT, PATCH or DELETE request
          typically represents an error (e.g. `status: :unprocessable_entity`).
        MSG

        RESPONDERS = {
          redirect_to: [REDIRECT_MSG, ", status: :see_other"],
          render: [RENDER_MSG, ", status: :unprocessable_entity"],
        }.freeze

        # @!method on_missing_status(node)
        def_node_search :on_missing_status, <<~PATTERN
          (send nil? {:render :redirect_to} ... !(hash <(pair (sym :status) _) ...>))
        PATTERN

        def on_def(node)
          return unless ACTIONS.include?(node.method_name)

          on_missing_status(node) do |responder|
            message, correction = RESPONDERS.fetch(responder.method_name)

            add_offense(responder, message: message) do |corrector|
              corrector.insert_after(responder, correction)
            end
          end
        end
      end
    end
  end
end
