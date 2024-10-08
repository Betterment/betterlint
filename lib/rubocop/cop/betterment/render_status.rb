# frozen_string_literal: true

require_relative 'utils/response_status'

module RuboCop
  module Cop
    module Betterment
      class RenderStatus < Base
        extend AutoCorrector

        include Utils::ResponseStatus

        MSG = <<~MSG.gsub(/\s+/, " ")
          Did you forget to specify an HTTP status code? The default is `status: :ok`, which might
          be inappropriate in this situation. Rendering after a POST, PUT, PATCH or DELETE request
          typically represents an error (e.g. `status: :unprocessable_entity`).
        MSG

        def on_def(node)
          each_offense(node, :render) do |responder|
            infer_status(responder)
          end
        end

        private

        def infer_status(responder)
          case extract_template(responder).to_s
          when 'new', 'edit'
            :unprocessable_entity
          else
            :ok
          end
        end

        # @!method extract_template(node)
        def_node_matcher :extract_template, <<~PATTERN
          (send nil? :render {(sym $_) (str $_)} ...)
        PATTERN
      end
    end
  end
end
