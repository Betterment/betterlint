# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::Utils::Parser do
  context 'when processing a statement' do
    it 'finds the root token for a bare send' do
      node = parse_source(<<~RUBY).ast
        method(:hello_world)
      RUBY

      expect(described_class.get_root_token(node)).to eq(:method)
    end

    it 'finds the root token for a send type' do
      node = parse_source(<<~RUBY).ast
        params.permit(:parameter)
      RUBY

      expect(described_class.get_root_token(node)).to eq(:params)
    end

    it 'finds the root token for a chained send' do
      node = parse_source(<<~RUBY).ast
        params.fetch(:parent, {}).permit(:username, :password)
      RUBY

      expect(described_class.get_root_token(node)).to eq(:params)
    end

    it 'finds the root token for a nested send' do
      node = parse_source(<<~RUBY).ast
        SomeObject.new(params.permit(:username, :password))
      RUBY

      expect(described_class.get_root_token(node)).to eq(:SomeObject)
    end

    it 'finds the root token for a send to a self node' do
      node = parse_source(<<~RUBY).ast
        self.parameter = 1
      RUBY

      expect(described_class.get_root_token(node)).to eq(:self)
    end

    it 'finds the root token for a send via block pass' do
      node = parse_source(<<~RUBY).ast
        some_method(&another_method)
      RUBY

      expect(described_class.get_root_token(node)).to eq(:some_method)
    end

    it 'finds the root token for a send to a module' do
      node = parse_source(<<~RUBY).ast
        Module::method.call(1, 2, 3)
      RUBY

      expect(described_class.get_root_token(node)).to eq(:Module)
    end
  end

  context 'when looking for return values' do
    it 'finds all the explicit return values' do
      node = parse_source(<<~RUBY).ast
        def some_method(arg)
          return 1 if arg.this?
          return 2 if arg.that?
        end
      RUBY

      expected_node_1 = parse_source('1').ast
      expected_node_2 = parse_source('2').ast

      expect(described_class.get_return_values(node)).to eq([expected_node_1, expected_node_2])
    end

    it 'finds all the implicit return values' do
      node = parse_source(<<~RUBY).ast
        def some_method(arg)
          true if arg.test?
        end
      RUBY

      expected_node = parse_source('true').ast

      expect(described_class.get_return_values(node)).to eq([expected_node])
    end

    it 'finds all the implicit and explicit return values' do
      node = parse_source(<<~RUBY).ast
        def some_method(arg)
          return 1 if arg.this?
          return 2 if arg.that?

          3
        end
      RUBY

      expected_node_1 = parse_source('1').ast
      expected_node_2 = parse_source('2').ast
      expected_node_3 = parse_source('3').ast

      expect(described_class.get_return_values(node)).to eq([expected_node_1, expected_node_2, expected_node_3])
    end

    it 'finds a compound statement return value' do
      node = parse_source(<<~RUBY).ast
        def some_method
          self.size + 1
        end
      RUBY

      expected_node = parse_source('self.size + 1').ast

      expect(described_class.get_return_values(node)).to eq([expected_node])
    end
  end

  context 'when extracting parameters' do
    it 'returns the single parameter name when accessing params as an array' do
      node = parse_source('params[:user_id]').ast

      expect(described_class.get_extracted_parameters(node)).to eq([:user_id])
    end

    it 'returns the various parameters when using params.permit' do
      node = parse_source('params.permit(:user_id, :name)').ast

      expect(described_class.get_extracted_parameters(node)).to eq(%i(user_id name))
    end

    it 'returns the parameters when accessing params through an alias' do
      node = parse_source('create_params[:user_id]').ast
      param_aliases = %i(create_params).freeze

      expect(described_class.get_extracted_parameters(node, param_aliases: param_aliases)).to eq([:user_id])
    end
  end

  context 'when extracting instance methods' do
    it 'raises an error for a non-node' do
      expect { described_class.get_instance_methods(nil) }.to raise_error(ArgumentError, 'must be a class node')
    end

    it 'raises an error for a non-class node' do
      node = parse_source('nil').ast

      expect { described_class.get_instance_methods(node) }.to raise_error(ArgumentError, 'must be a class node')
    end

    it 'tracks methods with a single return value' do
      node = parse_source(<<~RUBY).ast
        class Test
          def method
            1
          end
        end
      RUBY

      expected_node = parse_source('1').ast
      result = described_class.get_instance_methods(node)

      expect(result).to eql(method: [expected_node])
    end

    it 'tracks methods with multiple return values' do
      node = parse_source(<<~RUBY).ast
        class Test
          def method
            if condition
              1
            else
              2
            end
          end
        end
      RUBY

      expected_node_1 = parse_source('1').ast
      expected_node_2 = parse_source('2').ast
      result = described_class.get_instance_methods(node)

      expect(result).to eql(method: [expected_node_1, expected_node_2])
    end

    it 'tracks multiple methods' do
      node = parse_source(<<~RUBY).ast
        class Test
          def method_a
            1
          end

          def method_b
            2
          end
        end
      RUBY

      expected_node_1 = parse_source('1').ast
      expected_node_2 = parse_source('2').ast
      result = described_class.get_instance_methods(node)

      expect(result).to eql(method_a: [expected_node_1], method_b: [expected_node_2])
    end

    it 'tracks assignment statements with send types' do
      node = parse_source(<<~RUBY).ast
        class Test
          def method
            @var = call
          end
        end
      RUBY

      expected_node = parse_source('call').ast
      result = described_class.get_instance_methods(node)

      expect(result).to eql(method: [], :@var => [expected_node])
    end

    it 'handles empty class' do
      node = parse_source('class Test; end').ast
      result = described_class.get_instance_methods(node)

      expect(result).to eql({})
    end

    it 'ignores constant assignments and non-send assignments' do
      node = parse_source(<<~RUBY).ast
        class Test
          CONSTANT = call
          def method
            @number = 1
            @call = call
          end
        end
      RUBY

      expected_node = parse_source('call').ast
      result = described_class.get_instance_methods(node)

      expect(result).to eql(method: [], '@call': [expected_node])
    end
  end
end
