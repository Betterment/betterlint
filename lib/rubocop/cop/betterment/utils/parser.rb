# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      module Utils
        module Parser
          def self.get_root_token(node) # rubocop:disable Metrics/PerceivedComplexity, Metrics/AbcSize
            return nil unless node

            return get_root_token(node.receiver) if node.receiver

            # rubocop:disable InternalAffairs/NodeDestructuring
            if node.send_type?
              name = node.method_name
            elsif node.variable?
              name, = *node
            elsif node.literal?
              _, name = *node
            elsif node.const_type?
              name = node.const_name.to_sym
            elsif node.sym_type?
              name = node.value
            elsif node.self_type?
              name = :self
            elsif node.block_pass_type?
              name, = *node.children
            else
              name = nil
            end
            # rubocop:enable InternalAffairs/NodeDestructuring

            name
          end

          def self.get_return_values(node) # rubocop:disable Metrics/AbcSize
            return [] unless node
            return explicit_returns(node) + get_return_values(node.body) if node.def_type?
            return [node] if node.literal? || node.variable?

            case node.type
              when :begin
                get_return_values(node.children.last)
              when :block
                get_return_values(node.body)
              when :if
                if_rets = get_return_values(node.if_branch)
                else_rets = get_return_values(node.else_branch)
                if_rets + else_rets
              when :case
                cases = []
                node.each_when do |block|
                  cases += get_return_values(block.body)
                end

                cases + get_return_values(node.else_branch)
              when :send
                [node]
              else
                []
            end
          end

          def self.explicit_returns(node)
            node.descendants.select(&:return_type?).filter_map do |x|
              x&.children&.first
            end
          end

          def self.params_from_arguments(arguments) # rubocop:disable Metrics/PerceivedComplexity
            parameter_names = []

            arguments.each do |arg|
              if arg.hash_type?
                arg.children.each do |pair|
                  value = pair.value
                  parameter_names << value.value if value.sym_type? || value.str_type?
                end
              elsif arg.sym_type? || arg.str_type?
                parameter_names << arg.value
              end
            end

            parameter_names
          end

          def self.get_extracted_parameters(node, param_aliases: []) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
            return [] unless node.send_type?

            parameter_names = []
            param_aliases << :params

            if node.method?(:[]) && param_aliases.include?(get_root_token(node))
              return node.arguments.select { |x|
                x.sym_type? || x.str_type?
              }.map(&:value)
            end

            children = node.descendants.select do |child|
              child.send_type? && param_aliases.include?(child.method_name)
            end

            children.each do |child|
              ancestors = child.ancestors.select do |ancestor|
                ancestor.send_type? && ancestor.method?(:permit)
              end

              ancestors.each do |ancestor|
                parameter_names += params_from_arguments(ancestor.arguments)
              end
            end

            parameter_names.map(&:to_sym)
          end
        end
      end
    end
  end
end
