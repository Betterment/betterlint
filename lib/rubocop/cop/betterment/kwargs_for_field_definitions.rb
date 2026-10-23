# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class KwargsForFieldDefinitions < Base
        extend AutoCorrector

        MSG = 'Use `type:` and `description:` keyword arguments instead of positional arguments when defining a GraphQL field.'

        # @!method resolver_field?(node)
        def_node_matcher :resolver_field?, <<-PATTERN
          (send nil? :field ... (hash <(pair (sym {:resolver :mutation :subscription}) _) ...>))
        PATTERN

        # @!method positional_type(node)
        def_node_matcher :positional_type, <<-PATTERN
          (send nil? :field (sym _) $!hash ...)
        PATTERN

        # @!method positional_description(node)
        def_node_matcher :positional_description, <<-PATTERN
          (send nil? :field (sym _) !hash ${str dstr} ...)
        PATTERN

        def on_send(node)
          return if resolver_field?(node)

          type = positional_type(node)
          return unless type

          description = positional_description(node)

          add_offense(node) do |corrector|
            corrector.insert_before(type, 'type: ')
            corrector.insert_before(description, 'description: ') if description
          end
        end
        alias on_csend on_send
      end
    end
  end
end
