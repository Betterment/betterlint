# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class ResolverFieldType < Base
        MSG = 'Declare the type and `null:` on the resolver class, not on a field that uses it.'
        RESTRICT_ON_SEND = %i(field).freeze
        RESOLVER_OPTIONS = %i(resolver mutation subscription).freeze
        TYPE_OPTIONS = %i(type null).freeze

        def on_send(node)
          return unless field_with_resolver?(node)

          type_argument = positional_type(node)
          add_offense(type_argument) if type_argument

          type_options(node).each { |option| add_offense(option) }
        end
        alias on_csend on_send

        private

        def field_with_resolver?(node)
          node.receiver.nil? && any_option?(node, *RESOLVER_OPTIONS)
        end

        def positional_type(node)
          argument = node.arguments[1]
          return if argument.nil? || argument.hash_type?
          return if description?(node, argument)

          argument
        end

        # With `resolver:` or `mutation:` (not `subscription:`), graphql-ruby reads `field :x, "Some text", ...` as a description
        def description?(node, argument)
          argument.type?(:str, :dstr) &&
            node.arguments.size == 3 &&
            any_option?(node, :resolver, :mutation)
        end

        def type_options(node)
          option_pairs(node).select { |pair| TYPE_OPTIONS.include?(pair.key.value) }
        end

        def any_option?(node, *names)
          option_pairs(node).any? { |pair| names.include?(pair.key.value) }
        end

        def option_pairs(node)
          options = node.last_argument
          return [] unless options&.hash_type?

          options.pairs.select { |pair| pair.key.sym_type? }
        end
      end
    end
  end
end
