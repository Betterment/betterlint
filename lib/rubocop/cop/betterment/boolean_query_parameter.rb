# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class BooleanQueryParameter < Base
        MSG = <<~MSG
          A boolean fetched from query params will never be false when
          explicitly specified on the request. Please use
          ActiveModel::Type::Boolean.new.cast to cast the value to a boolean.
        MSG

        # @!method fetch_boolean?(node)
        def_node_matcher :fetch_boolean?, <<-PATTERN
          (send
            (send ...) :fetch
            (sym ...)
            (boolean))
        PATTERN

        # @!method boolean_cast?(node)
        def_node_search :boolean_cast?, <<-PATTERN
          (send
            (send
              (const
                (const
                  (const nil? :ActiveModel) :Type) :Boolean) :new) :cast
            ...)
        PATTERN

        # @!method action_controller?(node)
        def_node_search :action_controller?, <<~PATTERN
          {
            (const {nil? cbase} :ApplicationController)
            (const (const {nil? cbase} :ActionController) :Base)
          }
        PATTERN

        def on_send(node)
          return unless fetch_boolean?(node)

          return unless inherit_action_controller_base?(node)

          return if node.each_ancestor(:send).any? { |ancestor| boolean_cast?(ancestor) }

          add_offense(node)
        end

        private

        def inherit_action_controller_base?(node)
          class_node = node.each_ancestor(:class).first
          return false unless class_node

          action_controller?(class_node)
        end
      end
    end
  end
end
