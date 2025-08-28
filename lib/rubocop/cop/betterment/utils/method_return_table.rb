# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      module Utils
        module MethodReturnTable
          class << self
            def populate_index(node)
              raise "not a class" unless node.class_type?

              @indexed_methods = Parser.get_instance_methods(node)
            end

            def indexed_methods
              defined?(@indexed_methods) ? @indexed_methods : {}
            end

            def get_method(method_name)
              indexed_methods[method_name]
            end

            def has_method?(method_name)
              indexed_methods.include?(method_name)
            end
          end
        end
      end
    end
  end
end
