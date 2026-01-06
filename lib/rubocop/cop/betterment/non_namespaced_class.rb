# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class NonNamespacedClass < Base
        MSG = <<~TEXT.gsub(/\s+/, " ").strip
          Do not add new classes that are not namespaced underneath another constant.
          Classes should be defined within a module namespace (e.g., `module MyNamespace; class Foo; end; end`)
          or use the `::` syntax (e.g., `class MyNamespace::Foo`).
        TEXT

        def on_class(node)
          class_name_node = node.children[0]

          # Skip if the class name is nil (anonymous class)
          return unless class_name_node

          if class_name_node.const_type? && !namespaced?(class_name_node) && !inside_namespace?(node)
            add_offense(node)
          end
        end

        private

        def namespaced?(node)
          node.children.first&.const_type?
        end

        def inside_namespace?(node)
          node.each_ancestor(:module, :class).any?
        end
      end
    end
  end
end
