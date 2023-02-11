module RuboCop
  module Cop
    module Betterment
      class HardcodedID < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Hardcoded IDs cause flaky tests. Use a sequence instead.'.freeze

        # @!method key(node)
        def_node_matcher :key, '/^id$|_id$/'

        # @!method value(node)
        def_node_matcher :value, '{int | (str /^\d+$/)}'

        # @!method pair(node, value_pattern)
        def_node_matcher :pair, '(pair (sym #key) %1)'

        # @!method hardcoded_id?(node)
        def_node_matcher :hardcoded_id?, '#pair(#value)'

        # @!method references_hardcoded_id?(node, method_name)
        def_node_matcher :references_hardcoded_id?, '#pair((send nil? %1))'

        # @!method on_factory(node)
        def_node_matcher :on_factory, <<~PATTERN
          (send (const nil? :FactoryBot) {:create | :create_list} _factory ... (hash $...))
        PATTERN

        # @!method on_let_id(node)
        def_node_matcher :on_let_id, <<~PATTERN
          (block (send nil? {:let | :let!} (sym $#key)) _block_args $#value)
        PATTERN

        def on_send(node)
          each_factory_attribute(node) do |attribute_node|
            next unless hardcoded_id?(attribute_node)

            add_offense(attribute_node) do |corrector|
              attribute = Utils::HardcodedAttribute.new(attribute_node)
              correct_factory_usage(corrector, attribute) if attribute.correctable?
            end
          end
        end

        def on_block(node)
          on_let_id(node) do |name, value|
            node.parent&.each_descendant do |child|
              each_factory_attribute(child) do |attribute_node|
                next unless references_hardcoded_id?(attribute_node, name)

                add_offense(node) do |corrector|
                  attribute = Utils::HardcodedAttribute.new(attribute_node)
                  corrector.replace(attribute.node.value, value.value.to_s) if attribute.correctable?
                end
              end
            end
          end
        end
        alias on_numblock on_block

        private

        def each_factory_attribute(node, &block)
          on_factory(node) do |attributes|
            attributes.each(&block)
          end
        end

        def correct_factory_usage(corrector, attribute)
          corrector.remove(with_comma(attribute.node))

          attribute.each_integer_reference do |reference|
            corrector.replace(reference, attribute.replacement)
          end

          attribute.each_string_reference do |reference|
            attribute.each_range_within_string(reference) do |range|
              corrector.replace(range, "\#{#{attribute.replacement}}")
            end

            ensure_double_quoted(corrector, reference)
          end
        end

        def ensure_double_quoted(corrector, node)
          if node.source.start_with?("'")
            corrector.replace(node.loc.begin, '"')
            corrector.replace(node.loc.end, '"')
          end
        end

        def with_comma(attribute)
          range = attribute.location.expression
          range = range_with_surrounding_space(range: range)
          range_with_surrounding_comma(range, :left)
        end
      end
    end
  end
end
