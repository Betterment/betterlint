# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class SitePrismLoaded < Base
        extend AutoCorrector

        MSG = 'Use `be_loaded` instead of `be_displayed`'

        def_node_matcher :on_be_displayed, <<-PATTERN
          (send (send nil? :expect _) _ $(send nil? :be_displayed))
        PATTERN

        def on_send(node)
          on_be_displayed(node) do |be_displayed|
            add_offense(be_displayed) do |corrector|
              corrector.replace(be_displayed, 'be_loaded')
            end
          end
        end
      end
    end
  end
end
