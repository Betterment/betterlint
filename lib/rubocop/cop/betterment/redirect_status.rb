# frozen_string_literal: true

require_relative 'utils/response_status'

module RuboCop
  module Cop
    module Betterment
      class RedirectStatus < Base
        extend AutoCorrector

        include Utils::ResponseStatus

        MSG = <<~MSG.gsub(/\s+/, " ")
          Did you forget to specify an HTTP status code? The default is `status: :found`, which
          is usually inappropriate in this situation. Use `status: :see_other` when redirecting a
          POST, PUT, PATCH, or DELETE request to a GET resource.
        MSG

        def on_def(node)
          each_offense(node, :redirect_to) { :see_other }
        end
      end
    end
  end
end
