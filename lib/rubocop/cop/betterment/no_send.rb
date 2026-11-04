# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class NoSend < Base
        MSG = <<~TEXT
          Call the method directly instead of using `%<method>s`; dynamic dispatch is invisible to Sorbet and code search.

          See here for more information on this cop:
          https://github.com/Betterment/betterlint/blob/main/README.md#bettermentnosend
        TEXT

        RESTRICT_ON_SEND = %i(send public_send __send__).freeze

        def on_send(node)
          return unless node.arguments?

          add_offense(node.loc.selector, message: format(MSG, method: node.method_name))
        end
        alias on_csend on_send
      end
    end
  end
end
