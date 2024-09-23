# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class InternalsProtection < Base
        MSG = <<~END.gsub(/\s+/, " ")
          Internal constants may only be referenced from code within its containing module.
          Constants defined within a modules Internals submodule may only be referenced by code in that module,
          or nested classes and modules
          (e.g. MyModule::Internals::MyClass may only be referenced from code in MyModule or MyModule::MyPublicClass).
        END

        def on_const(node)
          if node.children[1] == :Internals
            module_path = containing_module_path(node)
            context_path = definition_context_path(node)

            unless module_path.empty? || context_path.each_cons(module_path.size).any?(module_path)
              add_offense(node)
            end
          end
        end

        private

        def containing_module_path(node)
          node.each_descendant(:const, :cbase).map { |n| n.children[1] }.reverse
        end

        def definition_context_path(node)
          node.each_ancestor(:class, :module).flat_map { |anc|
            anc.children[0].each_node(:const, :cbase).map { |c| c.children[1] }
          }.push(nil).reverse
        end
      end
    end
  end
end
