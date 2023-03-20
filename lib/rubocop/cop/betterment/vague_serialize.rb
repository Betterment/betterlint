module RuboCop
  module Cop
    module Betterment
      class VagueSerialize < Cop
        MSG = 'Active Record models with serialized columns should specify which deserializer to use instead of falling back to the default.'.freeze

        def_node_matcher :serialize?, <<-PATTERN
          (send nil? :serialize ...)
        PATTERN

        def on_send(node)
          return unless serialize? node

          add_offense(node) if node.arguments.length < 2 || !node.arguments[1].const_type?
        end
      end
    end
  end
end
