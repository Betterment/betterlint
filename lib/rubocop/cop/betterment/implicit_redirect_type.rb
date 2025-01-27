# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      # Require explicit redirect statuses in routes.rb. Permanent redirects (301) are cached by clients,
      # which makes it difficult to change later, and/or reuse the route for something else.
      #
      # @example
      #   # bad
      #   get '/', redirect('/dashboard')
      #   get { |params, request| '/dashboard' }
      #
      #   # good
      #   get '/', redirect('/dashboard', status: 301)
      #   get(status: 302) { |params, request| '/dashboard' }
      class ImplicitRedirectType < Base
        ROUTES_FILE_NAME = 'routes.rb'
        MSG =
          'Rails will create a permanent (301) redirect, which is dangerous. ' \
          'Please specify your desired status, e.g. redirect(..., status: 302)'

        # redirect('/')
        def_node_matcher :arg_form_without_options?, <<-PATTERN
          (send nil? :redirect (str _))
        PATTERN

        # redirect { |_params, _request| '/' }
        def_node_matcher :block_form_without_options?, <<-PATTERN
          (block (send nil? :redirect) ...)
        PATTERN

        # redirect('/', foo: 'bar')
        def_node_matcher :arg_form_with_options, <<-PATTERN
          (send nil? :redirect (str _) (hash $...))
        PATTERN

        # redirect(foo: 'bar') { |_params, _request| '/' }
        def_node_matcher :block_form_with_options, <<-PATTERN
          (block (send nil? :redirect (hash $...)) ...)
        PATTERN

        # status: anything
        def_node_matcher :valid_status_option?, <<-PATTERN
          (pair (sym :status) _)
        PATTERN

        def on_block(node)
          return unless routes_file?

          if block_form_with_options(node) { |options| options.none? { |n| valid_status_option?(n) } } || block_form_without_options?(node)
            add_offense(node)
          end
        end

        def on_send(node)
          return unless routes_file?

          if arg_form_with_options(node) { |options| options.none? { |n| valid_status_option?(n) } } || arg_form_without_options?(node)
            add_offense(node)
          end
        end
        alias on_csend on_send

        private

        def routes_file?
          Pathname.new(processed_source.file_path).basename.to_s == ROUTES_FILE_NAME
        end
      end
    end
  end
end
