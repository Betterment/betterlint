module RuboCop
  module Cop
    module Betterment
      class DynamicParams < Cop
        MSG_DYNAMIC_PARAMS = <<~MSG.freeze
          Parameter names accessed dynamically, cannot determine safeness. Please inline the keys explicitly when calling `permit` or when accessing `params` like a hash.

          See here for more information on this error:
          https://github.com/Betterment/betterlint/blob/main/README.md#bettermentdynamicparams
        MSG

        def_node_matcher :permit_or_hash?, <<-PATTERN
          (send (...) {:[] :permit} ...)
        PATTERN

        def on_send(node)
          _, _, *arg_nodes = *node # rubocop:disable InternalAffairs/NodeDestructuring
          return unless permit_or_hash?(node) && Utils::Parser.get_root_token(node) == :params

          dynamic_param = find_dynamic_param(arg_nodes)
          add_offense(dynamic_param, message: MSG_DYNAMIC_PARAMS) if dynamic_param
        end

        private

        def find_dynamic_param(arg_nodes)
          return unless arg_nodes

          arg_nodes.find do |arg|
            arg.array_type? && find_dynamic_param(arg.values) || !arg.literal? && !arg.const_type?
          end
        end
      end
    end
  end
end
