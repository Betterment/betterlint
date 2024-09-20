# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class Delay < Base
        DELAY_MESSAGE = 'Please use Active Job instead of using `Object#delay`'
        ENQUEUE_MESSAGE = 'Please use Active Job instead of using `Delayed::Job.enqueue`'

        # @!method enqueue?(node)
        def_node_matcher :enqueue?, <<-PATTERN
          (send (const (const nil? :Delayed) :Job) :enqueue ...)
        PATTERN

        def on_send(node)
          add_offense(node, message: DELAY_MESSAGE) if node.method?(:delay)
          add_offense(node, message: ENQUEUE_MESSAGE) if enqueue?(node)
        end
      end
    end
  end
end
