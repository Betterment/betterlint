module RuboCop
  module Cop
    module Utils
      module MethodReturnTable
        class << self
          def populate_index(node)
            raise "not a class" unless node.class_type?

            get_methods_for_class(node).each do |method|
              track_method(method.method_name, Utils::Parser.get_return_values(method))
            end

            node.descendants.each do |descendant|
              lhs, rhs = *descendant
              next unless descendant.equals_asgn? && (descendant.type != :casgn) && rhs&.send_type?

              track_method(lhs, [rhs])
            end
          end

          def indexed_methods
            @indexed_methods ||= {}
          end

          def get_method(method_name)
            indexed_methods[method_name]
          end

          def has_method?(method_name)
            indexed_methods.include?(method_name)
          end

          private

          def track_method(method_name, returns)
            indexed_methods[method_name] = returns
          end

          def get_methods_for_class(node)
            return [] unless node.children && node.class_type?

            node.descendants.select(&:def_type?)
          end
        end
      end
    end
  end
end
