module RuboCop
  module Cop
    module Betterment
      class NonStandardActions < Cop
        MSG_GENERAL = 'Use a new controller instead of custom actions.'.freeze
        MSG_RESOURCE_ONLY = "Resource route refers to a non-standard action in it's 'only:' param. #{MSG_GENERAL}".freeze
        MSG_ROUTE_TO = "Route goes to a non-standard controller action. #{MSG_GENERAL}".freeze

        # @!method routes?(node)
        def_node_matcher :routes?, <<-PATTERN
          (block (send (send (send (const nil? :Rails) :application) :routes) :draw) ...)
        PATTERN

        # @!method resource_with_only(node)
        def_node_matcher :resource_with_only, <<-PATTERN
          (send nil? {:resource :resources} _ (hash <(pair (sym :only) {(array (sym $_)*) (sym $_*)} ) ...> ))
        PATTERN

        def not_to_or_action?(sym)
          %i(to action).exclude?(sym)
        end

        # @!method route_to(node)
        def_node_matcher :route_to, <<~PATTERN
          (send nil? {:match :get :post :put :patch :delete} ({str sym} $_) (hash {
            <(pair (sym ${:to :action}) ({str sym} $_)) ...>
            (pair (sym $#not_to_or_action?) $_)*
          })?)
        PATTERN

        def on_block(node)
          if routes?(node)
            node.each_descendant(:send) do |descendant_node|
              check_resource_with_only(descendant_node) || check_raw_route(descendant_node)
            end
          end
        end

        private

        def check_resource_with_only(node)
          resource_only = resource_with_only(node)
          if resource_only && resource_only.any? { |action| !allowed_action?(action) }
            add_offense(node, message: MSG_RESOURCE_ONLY)
            true
          end
        end

        def check_raw_route(node)
          route = route_to(node)
          if route
            (path, param, value) = route
            action = case param
                       when :to then value.first.split('#').last
                       when :action then value.first
                       else path
                     end
            add_offense(node, message: MSG_ROUTE_TO) unless allowed_action?(action)
            true
          end
        end

        # NOTE: The InternalAffairs/UndefinedConfig rule seems to have a bug where it can't fine these configs in config/default.yml
        def allowed_actions
          @allowed_actions ||= cop_config['StandardActions'] + cop_config['AdditionalAllowedActions'] # rubocop:disable InternalAffairs/UndefinedConfig
        end

        def allowed_action?(action)
          allowed_actions.include?(action.to_s)
        end
      end
    end
  end
end
