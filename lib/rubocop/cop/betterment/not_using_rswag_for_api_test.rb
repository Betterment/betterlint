module RuboCop
  module Cop
    module Betterment
      class NotUsingRswagForApiTest < Cop
        MSG = <<-DOC.freeze
            Api tests should use https://github.com/rswag/rswag
            and not the built in `get`, `post`, `put`, `delete`
            methods
          DOC

        def_node_matcher :test_with_non_rswag_request?, <<-PATTERN
            (block (send nil? :it _) _  (begin (send nil? { :get :post} ...) ...))
          PATTERN

        def on_block(node)
          return unless test_with_non_rswag_request?(node)

          add_offense(node.children.last)
        end
      end
    end
  end
end
