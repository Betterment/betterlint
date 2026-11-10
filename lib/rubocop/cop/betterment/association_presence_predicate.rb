# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      class AssociationPresencePredicate < Base
        extend AutoCorrector

        PRESENCE_MSG = <<~TEXT
          Use `%<replacement>s` instead of `%<source>s`; it answers from the foreign key without loading `%<name>s`.

          See here for more information on this cop:
          https://github.com/Betterment/betterlint/blob/main/README.md#bettermentassociationpresencepredicate
        TEXT

        FOREIGN_KEY_MSG = <<~TEXT
          Use `has_%<name>s?` instead of checking `%<foreign_key>s`; it is also true when an unsaved `%<name>s` is assigned.

          See here for more information on this cop:
          https://github.com/Betterment/betterlint/blob/main/README.md#bettermentassociationpresencepredicate
        TEXT

        CHANGE_MSG = <<~TEXT
          Use `will_save_change_to_%<name>s?` instead of `%<method>s` before save; it also sees unsaved changes to a loaded `%<name>s`.

          See here for more information on this cop:
          https://github.com/Betterment/betterlint/blob/main/README.md#bettermentassociationpresencepredicate
        TEXT

        PRESENCE_METHODS = %i(present? nil? blank?).freeze
        NEGATED_PRESENCE_METHODS = %i(nil? blank?).freeze
        CONDITION_KEYS = %i(if unless).freeze
        SCOPE_BOUNDARIES = %i(class module sclass defs).freeze

        Association = Struct.new(:name, :foreign_key)

        # @!method belongs_to_declaration(node)
        def_node_matcher :belongs_to_declaration, <<~PATTERN
          (send nil? :belongs_to ({sym str} $_) ...)
        PATTERN

        # @!method foreign_key_option(node)
        def_node_matcher :foreign_key_option, <<~PATTERN
          (send nil? :belongs_to _ ... (hash <(pair (sym :foreign_key) $_) ...>))
        PATTERN

        # @!method instance_call(node)
        def_node_matcher :instance_call, <<~PATTERN
          (send {nil? (self)} $_)
        PATTERN

        # @!method condition_value(node)
        def_node_matcher :condition_value, <<~PATTERN
          (pair (sym {#{CONDITION_KEYS.map(&:inspect).join(' ')}}) ${sym (array sym+)})
        PATTERN

        def on_class(node)
          body = node.body or return
          statements = body.begin_type? ? body.children : [body]
          defined_methods = statements.select(&:def_type?).map(&:method_name)
          associations = statements.filter_map { |statement| association_for(statement, defined_methods) }
          return if associations.empty?

          each_instance_node(node) { |descendant| check(descendant, associations) }
        end

        private

        def association_for(statement, defined_methods)
          name = belongs_to_declaration(statement) or return
          name = name.to_s
          return if [name, "has_#{name}?", "will_save_change_to_#{name}?"].any? { |method| defined_methods.include?(method.to_sym) }

          Association.new(name, foreign_key_for(statement, name))
        end

        def foreign_key_for(statement, name)
          value = foreign_key_option(statement) or return "#{name}_id"
          value.value.to_s if value.type?(:sym, :str)
        end

        def each_instance_node(node, &block)
          node.each_child_node do |child|
            next if SCOPE_BOUNDARIES.include?(child.type)

            yield child
            each_instance_node(child, &block)
          end
        end

        def check(node, associations)
          if node.send_type?
            check_presence(node, associations)
            check_method(node, instance_call(node), associations) if node.arguments.empty?
          elsif node.pair_type?
            condition_value(node) do |value|
              symbols = value.sym_type? ? [value] : value.children
              symbols.each { |symbol| check_method(symbol, symbol.value, associations) }
            end
          end
        end

        def check_presence(node, associations)
          return unless PRESENCE_METHODS.include?(node.method_name) && node.arguments.empty?

          reader = instance_call(node.receiver) or return
          association = associations.find { |candidate| candidate.name == reader.to_s }
          return add_presence_offense(node, association) if association

          association = associations.find { |candidate| candidate.foreign_key == reader.to_s }
          add_offense(node, message: format(FOREIGN_KEY_MSG, name: association.name, foreign_key: association.foreign_key)) if association
        end

        def add_presence_offense(node, association)
          negated = NEGATED_PRESENCE_METHODS.include?(node.method_name)
          target = node
          if node.parent&.send_type? && node.parent.method?(:!) && node.parent.receiver == node
            target = node.parent
            negated = !negated
          end

          replacement = "#{'!' if negated}has_#{association.name}?"
          message = format(PRESENCE_MSG, replacement: replacement, source: target.source, name: association.name)
          add_offense(target, message: message) do |corrector|
            corrector.replace(target, negated && receiver_of_parent?(target) ? "(#{replacement})" : replacement)
          end
        end

        def receiver_of_parent?(node)
          node.parent&.send_type? && node.parent.receiver == node
        end

        def check_method(node, method, associations)
          return unless method

          method = method.to_s
          associations.each do |association|
            foreign_key = association.foreign_key or next
            if method == "#{foreign_key}?"
              add_offense(node, message: format(FOREIGN_KEY_MSG, name: association.name, foreign_key: method))
            elsif ["#{foreign_key}_changed?", "will_save_change_to_#{foreign_key}?"].include?(method) && !in_after_callback?(node)
              add_offense(node, message: format(CHANGE_MSG, name: association.name, method: method))
            end
          end
        end

        def in_after_callback?(node)
          node.each_ancestor(:send).any? { |ancestor| ancestor.receiver.nil? && ancestor.method_name.start_with?('after_') }
        end
      end
    end
  end
end
