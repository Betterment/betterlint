# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class SitePrismLoaded < Cop
        MSG = 'Use `be_loaded` instead of `be_displayed`'

        def_node_matcher :be_displayed_call?, <<-PATTERN
          (send (send nil? :expect _) _ (send nil? :be_displayed))
        PATTERN

        def on_send(node)
          return unless be_displayed_call?(node)

          add_offense(node, location: node.children[2].source_range)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.children[2], 'be_loaded')
          end
        end
      end
    end
  end
end
