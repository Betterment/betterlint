# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class InternalsProtection < Base
        MSG = <<~END.gsub(/\s+/, " ")
          Internal constants may only be referenced from code within its containing module.
          Constants defined within a module's Internals submodule may only be referenced by code in that module,
          or nested classes and modules
          (e.g. MyModule::Internals::MyClass may only be referenced from code in MyModule or MyModule::MyPublicClass).
        END

        # @!method association_with_class_name(node)
        def_node_matcher :association_with_class_name, <<-PATTERN
          (send nil? {:has_many :has_one :belongs_to} ... (hash <(pair (sym :class_name) ${str _}) ...>))
        PATTERN

        # @!method rspec_describe(node)
        def_node_matcher :rspec_describe, <<-PATTERN
          (block (send (const nil? :RSpec) :describe ${const | str}) ...)
        PATTERN


        def on_const(node)
          if node.children[1] == :Internals
            module_path = const_path(node)

            ensure_allowed_reference!(node, module_path)
          end
        end

        def on_send(node)
          class_name_node = association_with_class_name(node)
          return unless class_name_node

          full_path = string_path(class_name_node)
          internals_index = full_path.find_index(:Internals)
          if internals_index
            module_path = full_path.take(internals_index)
            ensure_allowed_reference!(class_name_node, module_path)
          end
        end

        private

        def ensure_allowed_reference!(node, module_path)
          return if module_path.empty?

          unless definition_context_path(node).each_cons(module_path.size).any?(module_path)
            add_offense(node)
          end
        end

        def const_path(const_node)
          const_node.each_descendant(:const, :cbase).map { |n| n.children[1] }.reverse
        end

        def string_path(string_node)
          string_node.children[0].split('::').map { |name| name == '' ? nil : name.to_sym }
        end

        def definition_context_path(node)
          rspec_context_path(node) || module_class_definition_context_path(node)
        end

        def module_class_definition_context_path(node)
          node.each_ancestor(:class, :module).flat_map { |anc|
            anc.children[0].each_node(:const, :cbase).map { |c| c.children[1] }
          }.push(nil).reverse
        end

        def rspec_context_path(node)
          rspec_described_class = node.each_ancestor(:block).filter_map do |ancestor|
            rspec_describe(ancestor)
          end.first
          case rspec_described_class&.type
            when :const then const_path(rspec_described_class)
            when :str then string_path(rspec_described_class)
            else nil
          end
        end
      end
    end
  end
end
