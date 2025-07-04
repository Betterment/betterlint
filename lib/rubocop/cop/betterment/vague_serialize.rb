# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class VagueSerialize < Base
        MSG = 'Active Record models with serialized columns should specify which ' \
              'deserializer to use instead of falling back to the default.'

        # @!method serialize?(node)
        def_node_matcher :serialize?, <<-PATTERN
          (send nil? :serialize ...)
        PATTERN

        # @!method kwargs_with_coder?(node)
        def_node_matcher :kwargs_with_coder?, '(hash <(pair (sym :coder) const) ...>)'

        # @!method valid_serialize?(node)
        def_node_matcher :valid_serialize?, <<-PATTERN
          (send nil? :serialize _ { const !#kwargs_with_coder?? | #kwargs_with_coder? })
        PATTERN

        def on_send(node)
          add_offense(node) if serialize?(node) && !valid_serialize?(node)
        end
        alias on_csend on_send
      end
    end
  end
end
