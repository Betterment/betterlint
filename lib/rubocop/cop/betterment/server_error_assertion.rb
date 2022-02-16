# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      # Checks the status passed to have_http_status
      #
      # If a number, enforces that it doesn't start with 5. If a symbol or a string, enforces that it's not one of:
      #
      # * internal_server_error
      # * not_implemented
      # * bad_gateway
      # * service_unavailable
      # * gateway_timeout
      # * http_version_not_supported
      # * insufficient_storage
      # * not_extended
      #
      # @example
      #
      #     # bad
      #     expect(response).to have_http_status :internal_server_error
      #
      #     # bad
      #     expect(response).to have_http_status 500
      #
      #     # good
      #     expect(response).to have_http_status :forbidden
      #
      #     # good
      #     expect(response).to have_http_status 422
      class ServerErrorAssertion < Base
        MSG = 'Do not assert on 5XX statuses. Use a semantic status (e.g., 403, 422, etc.) or treat them as bugs (omit tests).'
        BAD_STATUSES = %i(
          internal_server_error
          not_implemented
          bad_gateway
          service_unavailable
          gateway_timeout
          http_version_not_supported
          insufficient_storage
          not_extended
        ).freeze

        def_node_matcher :offensive_node?, <<-PATTERN
          (send nil? :have_http_status
            {
              (int {#{(500..599).map(&:to_s).join(' ')}})
              (str {#{BAD_STATUSES.map(&:to_s).map(&:inspect).join(' ')}})
              (sym {#{BAD_STATUSES.map(&:inspect).join(' ')}})
            }
          )
        PATTERN

        def on_send(node)
          return unless offensive_node?(node)

          add_offense(node)
        end
      end
    end
  end
end
