module RuboCop
  module Cop
    module Betterment
      class ActiveJobPerformable < Cop
        MSG = <<~DOC.freeze
          Classes that are "performable" should be ActiveJobs

          class MyJob < ApplicationJob
            def perform
            end
          end

          You can learn more about ActiveJob here:
          https://guides.rubyonrails.org/active_job_basics.html
        DOC

        def_node_matcher :subclasses_application_job?, <<-PATTERN
          (class (const ...) (const _ :ApplicationJob) ...)
        PATTERN

        def_node_matcher :is_perform_method?, <<-PATTERN
          (def :perform ...)
        PATTERN

        def on_class(node)
          return unless has_perform_method?(node)
          return if subclasses_application_job?(node)

          add_offense(node.identifier)
        end

        private

        def has_perform_method?(node)
          is_perform_method?(node.body)
        end
      end
    end
  end
end
