# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class Environment < Base
        MSG =
          "Environment variables should be parsed at boot time and assigned " \
          "to `Rails.configuration` or some other configurable object."

        # @!method env?(node)
        def_node_matcher :env?, '(const nil? :ENV)'

        def on_const(node)
          add_offense(node) if env?(node)
        end
      end
    end
  end
end
