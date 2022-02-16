module RuboCop
  module Cop
    module Betterment
      class UnsafeJob < Cop
        attr_accessor :sensitive_params, :class_regex

        MSG = <<~MSG.freeze
          This job takes a parameter that will end up serialized in plaintext. Do not pass sensitive data as bare arguments into jobs.

          See here for more information on this error:
          https://github.com/Betterment/betterlint#bettermentunsafejob
        MSG

        def initialize(config = nil, options = nil)
          super(config, options)
          config = @config.for_cop(self)
          @sensitive_params = config.fetch("sensitive_params", []).map(&:to_sym)
          @class_regex = Regexp.new config.fetch("class_regex", ".*Job$")
        end

        def on_def(node)
          return unless %i(perform initialize).include?(node.method_name)
          return unless @class_regex.match(node.parent_module_name)

          node.arguments.any? do |argument|
            name, = *argument
            add_offense(argument) if @sensitive_params.include?(name)
          end
        end
      end
    end
  end
end
