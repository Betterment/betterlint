# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class Delay < Base
        MESSAGE = 'Please use Active Job instead of using `Object#delay`'

        def on_send(node)
          add_offense(node, message: MESSAGE) if node.method?(:delay)
        end
      end
    end
  end
end
