# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class NoNotImplementedError < Base
        MSG = 'Ruby reserves `NotImplementedError` for platform limitations. Use an abstract method or a specific application error.'

        # @!method not_implemented_error?(node)
        def_node_matcher :not_implemented_error?, '(const {nil? (cbase) (const {nil? (cbase)} :Object)} :NotImplementedError)'

        def on_const(node)
          add_offense(node) if not_implemented_error?(node)
        end
      end
    end
  end
end
