# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class UnscopedFind < Cop
        attr_accessor :unauthenticated_models

        MSG = <<~MSG
          Records are being retrieved directly using user input.
          Please query for the associated record in a way that enforces authorization (e.g. "trust-root chaining").

          INSTEAD OF THIS:
          Post.find(params[:post_id])

          DO THIS:
          current_user.posts.find(params[:post_id])

          See here for more information on this error:
          https://github.com/Betterment/betterlint/blob/main/README.md#bettermentunscopedfind
        MSG
        METHOD_PATTERN = /^find_by_(.+?)(!)?$/
        FINDS = %i(find find_by find_by! where).freeze
        GRAPHQL_PATTERN = /\bGraphQL\b/i

        def_node_matcher :custom_scope_find?, <<-PATTERN
          (send (send (const ... _) ...) {#{FINDS.map(&:inspect).join(' ')}} ...)
        PATTERN

        def_node_matcher :find?, <<-PATTERN
          (send (const ... _) {#{FINDS.map(&:inspect).join(' ')}} ...)
        PATTERN

        def initialize(config = nil, options = nil)
          super(config, options)
          config = @config.for_cop(self)
          @unauthenticated_models = config.fetch("unauthenticated_models", []).map(&:to_sym)
        end

        def on_class(node)
          Utils::MethodReturnTable.populate_index(node)
        end

        def on_send(node)
          _, _, *arg_nodes = *node # rubocop:disable InternalAffairs/NodeDestructuring
          return unless
            (
                find?(node) ||
                custom_scope_find?(node) ||
                static_method_name(node.method_name)
            ) && !@unauthenticated_models.include?(Utils::Parser.get_root_token(node))

          add_offense(node) if find_param_arg(arg_nodes) || graphql_namespace?(node)
        end

        private

        def graphql_namespace?(node)
          return true if processed_source.path&.match?(GRAPHQL_PATTERN)

          node
            .ancestors
            .select { |n| n.class_type? || n.module_type? }
            .any? { |n| n.identifier.to_s.match?(GRAPHQL_PATTERN) }
        end

        def find_param_arg(arg_nodes)
          return unless arg_nodes

          arg_nodes.find do |arg|
            if arg.hash_type?
              arg.children.each do |pair|
                _key, value = *pair.children
                return arg if uses_params?(value)
              end
            end

            uses_params?(arg)
          end
        end

        def uses_params?(node)
          root = Utils::Parser.get_root_token(node)
          root == :params || Array(Utils::MethodReturnTable.get_method(root)).find do |x|
            Utils::Parser.get_root_token(x) == :params
          end
        end

        # yoinked from Rails/DynamicFindBy
        def static_method_name(method_name)
          match = METHOD_PATTERN.match(method_name)
          return nil unless match

          match[2] ? 'find_by!' : 'find_by'
        end
      end
    end
  end
end
