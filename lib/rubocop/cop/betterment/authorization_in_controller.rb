# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class AuthorizationInController < Base
        attr_accessor :unsafe_parameters, :unsafe_regex

        # MSG_UNSAFE_CREATE = 'Model created/updated using unsafe parameters'.freeze
        MSG_UNSAFE_CREATE = <<~MSG
          Model created/updated using unsafe parameters.
          Please query for the associated record in a way that enforces authorization (e.g. "trust-root chaining"),
          and then pass the resulting object into your model instead of the unsafe parameter.

          INSTEAD OF THIS:
          post_parameters = params.permit(:album_id, :caption)
          Post.new(post_parameters)

          DO THIS:
          album = current_user.albums.find(params[:album_id])
          post_parameters = params.permit(:caption).merge(album: album)
          Post.new(post_parameters)

          See here for more information on this error:
          https://github.com/Betterment/betterlint/blob/main/README.md#bettermentauthorizationincontroller
        MSG

        def_node_matcher :model_new?, <<-PATTERN
          (send (const ... _) {:new :build :create :create! :find_or_create_by :find_or_create_by! :find_or_initialize_by :find_or_initialize_by!} ...)
        PATTERN

        def_node_matcher :model_update?, <<-PATTERN
          (send (...) {:assign_attributes :update :update! :find_or_create_by :find_or_create_by! :find_or_initialize_by :find_or_initialize_by! :update_attribute :update_attributes :update_attributes! :update_all :update_column :update_columns} ...)
        PATTERN

        def initialize(config = nil, options = nil)
          super
          @unsafe_parameters = cop_config.fetch("unsafe_parameters", []).map(&:to_sym)
          @unsafe_regex = Regexp.new cop_config.fetch("unsafe_regex", ".*_id$")
          @param_wrappers = []
        end

        def on_class(node)
          Utils::MethodReturnTable.populate_index node
          Utils::MethodReturnTable.indexed_methods.each do |method_name, method_returns|
            method_returns.each do |x|
              name = Utils::Parser.get_root_token(x)
              @param_wrappers << method_name if name == :params || @param_wrappers.include?(name)
            end
          end
        end

        def on_send(node) # rubocop:disable Metrics/PerceivedComplexity
          return if !model_new?(node) && !model_update?(node)

          node.arguments.each do |argument|
            if argument.send_type? || argument.variable?
              flag_literal_param_use(argument)
              flag_indirect_param_use(argument)
            elsif argument.hash_type?
              argument.children.select(&:pair_type?).each do |pair|
                _key, value = *pair.children
                flag_literal_param_use(value)
                flag_indirect_param_use(value)
              end
            end
          end
        end
        alias on_csend on_send

        private

        # Flags objects being created/updated with unsafe
        # params directly from params or through params.permit
        #
        # class MyController < ApplicationController
        #   def create
        #     Object.create params.permit(:user_id)
        #     Object.create(user_id: params[:user_id])
        #   end
        # end
        #
        def flag_literal_param_use(node)
          name = Utils::Parser.get_root_token(node)
          extracted_params = Utils::Parser.get_extracted_parameters(node)
          add_offense(node, message: MSG_UNSAFE_CREATE) if name == :params && contains_id_parameter?(extracted_params)
        end

        # Flags objects being created/updated with unsafe
        # params indirectly from params or through params.permit
        def flag_indirect_param_use(node) # rubocop:disable Metrics/PerceivedComplexity
          name = Utils::Parser.get_root_token(node)
          # extracted_params contains parameters used like:
          # def create
          #   Object.new(user_id: indirect_params[:user_id])
          # end
          # def indirect_params
          #   params.permit(:user_id)
          # end
          extracted_params = Utils::Parser.get_extracted_parameters(node, param_aliases: @param_wrappers)

          returns = Utils::MethodReturnTable.get_method(name) || []
          returns.each do |ret|
            # # propagated_params contains parameters used like:
            # def create
            #   Object.new indirect_params
            # end
            # def indirect_params
            #   params.permit(:user_id)
            # end
            propagated_params = Utils::Parser.get_extracted_parameters(ret, param_aliases: @param_wrappers)

            # # internal_params contains parameters used like:
            # def create
            #   Object.new(user_id: indirect_params)
            # end
            # def indirect_params
            #   params[:user_id]
            # end
            if ret.send_type? && ret.method?(:[])
              internal_params = ret.arguments.select { |x| x.type?(:sym, :str) }.map(&:value)
            else
              internal_returns = Utils::MethodReturnTable.get_method(Utils::Parser.get_root_token(ret)) || []
              internal_params = internal_returns.flat_map { |x| Utils::Parser.get_extracted_parameters(x, param_aliases: @param_wrappers) }
            end

            add_offense(node, message: MSG_UNSAFE_CREATE) if flag_indirect_param_use?(extracted_params, internal_params, propagated_params)
          end
        end

        def flag_indirect_param_use?(extracted_params, internal_params, propagated_params)
          return contains_id_parameter?(extracted_params) if extracted_params.any?

          contains_id_parameter?(extracted_params) || contains_id_parameter?(internal_params) || contains_id_parameter?(propagated_params)
        end

        def contains_id_parameter?(params)
          params.any? do |arg|
            suspicious_id?(arg)
          end
        end

        # check a symbol name against the cop's config parameters
        def suspicious_id?(symbol_name)
          @unsafe_parameters.include?(symbol_name.to_sym) || @unsafe_regex.match(symbol_name) # symbol_name.to_s.end_with?("_id")
        end
      end
    end
  end
end
