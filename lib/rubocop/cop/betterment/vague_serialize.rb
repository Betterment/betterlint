# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class VagueSerialize < Base
        MSG = <<~MESSAGE
          Active Record models with serialized columns should specify which deserializer to use instead of falling back to the default.

          If you are using Rails <= 7.0, stick with a positional argument. E.g.
            `serialize :foo, MyCoderClass`

          If you are using Rails >= 7.1, use the `coder` kwarg, since the positional arg was deprecated
            e.g. `serialize :foo, coder: MyCoderClass`
        MESSAGE

        # @!method serialize?(node)
        def_node_matcher :serialize?, <<-PATTERN
          (send nil? :serialize ...)
        PATTERN

        # @!method kwargs_with_coder?(node)
        def_node_matcher :kwargs_with_coder?, '(hash <(pair (sym :coder) (const ...)) ...>)'

        def on_send(node)
          return unless serialize? node

          coder_args = node.arguments[1..].select { |arg| arg.const_type? || kwargs_with_coder?(arg) }

          add_offense(node) if node.arguments.length < 2 || coder_args.length != 1
        end
        alias on_csend on_send
      end
    end
  end
end
