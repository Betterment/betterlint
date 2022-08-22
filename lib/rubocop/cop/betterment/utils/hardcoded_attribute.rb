module RuboCop
  module Cop
    module Utils
      class HardcodedAttribute
        extend RuboCop::NodePattern::Macros

        attr_reader :node, :let_node, :let_name

        def initialize(node)
          @node = node
          @let_node = node.parent&.parent&.parent
          @let_name = extract_let_name(@let_node)
        end

        def correctable?
          key == :id && !let_name.nil?
        end

        def replacement
          "#{let_name}.#{key}"
        end

        def each_integer_reference
          each_possible_reference(:int) do |ref|
            yield ref if ref.value == value
          end
        end

        def each_string_reference
          each_possible_reference(:str) do |ref|
            yield ref if ref.value.match?(value_pattern)
          end
        end

        def each_range_within_string(reference)
          reference.source.enum_for(:scan, value_pattern).each do
            yield create_range(reference, Regexp.last_match)
          end
        end

        private

        def create_range(node, match)
          range = node.loc.expression
          begin_pos = range.begin_pos + match.begin(0)
          end_pos = range.begin_pos + match.end(0)
          range.with(begin_pos: begin_pos, end_pos: end_pos)
        end

        def key
          node.key.value
        end

        def value
          node.value.value.to_i
        end

        def value_pattern
          /\b#{value}\b/
        end

        def each_possible_reference(type, &block)
          let_node.parent.each_descendant(:block) do |block_node|
            block_node.each_descendant(type, &block) unless block_node == let_node
          end
        end

        # @!method extract_let_name(node)
        def_node_matcher :extract_let_name, <<~PATTERN
          (block (send nil? {:let | :let!} (sym $_let_name)) _block_args _block_body)
        PATTERN
      end
    end
  end
end
