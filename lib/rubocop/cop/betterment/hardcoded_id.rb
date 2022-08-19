module RuboCop
  module Cop
    module Betterment
      class HardcodedID < Base
        MSG = 'Hardcoded IDs cause flaky tests. Use a sequence instead.'.freeze

        # @!method key(node)
        def_node_matcher :key, '/^id$|_id$/'

        # @!method value(node)
        def_node_matcher :value, '{int | (str /^\d+$/)}'

        # @!method pair(node, value_pattern)
        def_node_matcher :pair, '(pair (sym #key) %1)'

        # @!method on_hardcoded_id(node)
        def_node_matcher :on_hardcoded_id, '#pair(#value)'

        # @!method on_hardcoded_id_reference(node, method_name)
        def_node_matcher :on_hardcoded_id_reference, '#pair((send nil? %1))'

        # @!method on_factory(node)
        def_node_matcher :on_factory, <<~PATTERN
          (send (const nil? :FactoryBot) {:create | :create_list} _name ... (hash $...))
        PATTERN

        # @!method on_let_id(node)
        def_node_matcher :on_let_id, <<~PATTERN
          (block (send nil? :let (sym $#key)) _block_args #value)
        PATTERN

        def on_send(node)
          on_factory_attribute(node) do |attribute|
            on_hardcoded_id(attribute) do
              add_offense(attribute)
            end
          end
        end

        def on_block(node)
          on_let_id(node) do |name|
            node.parent&.each_descendant do |child|
              on_factory_attribute(child) do |attribute|
                on_hardcoded_id_reference(attribute, name) do
                  add_offense(node)
                end
              end
            end
          end
        end
        alias on_numblock on_block

        private

        def on_factory_attribute(node, &block)
          on_factory(node) do |attributes|
            attributes.each(&block)
          end
        end
      end
    end
  end
end
