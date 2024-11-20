# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class NotUsingRswag < Base
        MSG = 'Ensure request spec conforms to the required structure.'

        def on_new_investigation
          return if processed_source.ast.nil?

          unless valid_path_structure?(processed_source.ast)
            add_offense(processed_source.ast)
          end
        end

        private

        def valid_path_structure?(node)
          node.each_descendant.any? do |descendant|
            next unless path_node?(descendant)

            find_method_and_response_nodes(descendant)
          end
        end

        def find_method_and_response_nodes(node)
          method_found = false
          response_found = false

          node.each_descendant do |descendant|
            method_found ||= method_node?(descendant)
            response_found ||= response_node?(descendant)
            break if method_found && response_found
          end

          method_found && response_found
        end

        # @!method path_with_code?(node)
        def_node_matcher :path_with_code?, <<~PATTERN
          (block
            (send nil? :path (str _))
            args
            !nil?)
        PATTERN

        # @!method path_node?(node)
        def_node_matcher :path_node?, <<~PATTERN
          (block
            (send nil? :path (str _))
            args
            _)
        PATTERN

        # @!method method_node?(node)
        def_node_matcher :method_node?, <<~PATTERN
          (block
            (send nil? {:get :post :put :patch :delete} str)
            args
            _)
        PATTERN

        # @!method response_node?(node)
        def_node_matcher :response_node?, <<~PATTERN
          (block
            (send nil? :response str str)
            args
            _)
        PATTERN
      end
    end
  end
end
