# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class NonStandardController < RuboCop::Cop::Base
        MSG = <<~END.gsub(/\s+/, " ")
          `resources` and `resource` should not need to specify a `controller` option.
          If your controller lives in a module, please use the `module` option. Otherwise,
          please rename your controller to match your routes.
        END

        # @!method resources_with_controller(node)
        def_node_matcher :resources_with_controller, <<~PATTERN
          (send _ {:resources | :resource} _ (hash <$(pair (sym :controller) _) ...>))
        PATTERN

        def on_send(node)
          resources_with_controller(node) { |option| add_offense(option) }
        end
      end
    end
  end
end
