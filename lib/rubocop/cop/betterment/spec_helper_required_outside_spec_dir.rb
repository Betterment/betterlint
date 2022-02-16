module RuboCop
  module Cop
    module Betterment
      # If a file requires spec_helper or rails_helper, make sure
      # it is located in a spec/ directory.
      #
      # @example
      #   # bad
      #   app/models/whatever_spec.rb
      #   require 'rails_helper'
      #
      #   # good
      #   spec/models/my_class_spec.rb
      #   require 'rails_helper'
      class SpecHelperRequiredOutsideSpecDir < Base
        MSG = 'Spec helper required outside of a spec/ directory.'.freeze

        def_node_matcher :requires_spec_helper?, <<-PATTERN
          (send nil? :require
            (str {"rails_helper" "spec_helper"}))
        PATTERN

        def on_send(node)
          add_offense(node) if requires_spec_helper?(node) && !spec_directory?
        end

        private

        def spec_directory?
          Pathname.new(processed_source.buffer.name)
            .relative_path_from(Pathname.pwd)
            .to_s
            .start_with?("spec#{File::SEPARATOR}")
        end
      end
    end
  end
end
