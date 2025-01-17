# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      module UseGlobalStrictLoading
        # This cop ensures that `self.strict_loading_by_default = <any value>` is not set in ActiveRecord models.
        class ByDefaultForModels < Base
          extend AutoCorrector
          include RangeHelp

          MSG = 'Do not set `self.strict_loading_by_default` in ActiveRecord models.'

          # @!method strict_loading_by_default_set?(node)
          def_node_matcher :strict_loading_by_default_set?, <<~PATTERN
            $(send self :strict_loading_by_default= _)
          PATTERN

          def on_send(node)
            strict_loading_by_default_set?(node) do |method_call|
              add_offense(method_call) do |corrector|
                corrector.remove(method_call)
              end
            end
          end
        end

        # This cop ensures that `strict_loading: <any value>` is not set in ActiveRecord associations.
        class ForAssociations < Base
          extend AutoCorrector
          include RangeHelp

          MSG = 'Do not set `:strict_loading` in ActiveRecord associations.'

          ASSOCIATION_METHODS = %i(belongs_to has_and_belongs_to_many has_many has_one).freeze

          # @!method association_with_strict_loading?(node)
          def_node_matcher :association_with_strict_loading?, <<~PATTERN
            (send nil? {#{ASSOCIATION_METHODS.map(&:inspect).join(' ')}} ... (hash <$(pair (sym :strict_loading) ...) ...>))
          PATTERN

          def on_send(node)
            association_with_strict_loading?(node) do |pair|
              add_offense(node) do |corrector|
                corrector.remove(range_with_surrounding_comma(range_with_surrounding_space(range: pair.source_range, side: :left), :left))
              end
            end
          end
        end
      end
    end
  end
end
