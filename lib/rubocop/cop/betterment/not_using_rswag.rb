# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class NotUsingRswag < Base
        MSG = 'Request specs must use rswag to test and document their API endpoints. See: https://github.com/rswag/rswag'

        def on_block(node)
          # Only run from root Rspec.describe block
          return unless rspec_describe?(node)

          # If the block descendants contain rswag structure, it's valid
          return if contains_rswag_structure?(node)

          # Otherwise, add offense
          add_offense(node)
        end

        private

        def contains_rswag_structure?(node)
          has_path_block?(node) &&
            has_http_method_block?(node) &&
            has_response_block?(node)
        end

        # @!method rspec_describe?(node)
        def_node_matcher :rspec_describe?, <<~PATTERN
          (block
            (send
              (const nil? :RSpec) :describe ...)
            ...)
        PATTERN

        # @!method has_path_block?(node)
        def_node_matcher :has_path_block?, <<~PATTERN
          `(block
            (send nil? :path (str _))
            ...)
        PATTERN

        # @!method has_http_method_block?(node)
        def_node_matcher :has_http_method_block?, <<~PATTERN
          `(block
            (send nil? {:get :post :put :patch :delete} (str _))
            ...)
        PATTERN

        # @!method has_response_block?(node)
        def_node_matcher :has_response_block?, <<~PATTERN
          `(block
            (send nil? :response (str _) (str _))
            ...)
        PATTERN
      end
    end
  end
end
