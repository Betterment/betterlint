require 'spec_helper'

describe RuboCop::Cop::Utils::Parser do
  context 'when processing a statement' do
    it 'finds the root token for a bare send' do
      node = parse_source(<<-DEF).ast
        method(:hello_world)
      DEF

      expect(described_class.get_root_token(node)).to eq(:method)
    end

    it 'finds the root token for a send type' do
      node = parse_source(<<-DEF).ast
        params.permit(:parameter)
      DEF

      expect(described_class.get_root_token(node)).to eq(:params)
    end

    it 'finds the root token for a chained send' do
      node = parse_source(<<-DEF).ast
        params.fetch(:parent, {}).permit(:username, :password)
      DEF

      expect(described_class.get_root_token(node)).to eq(:params)
    end

    it 'finds the root token for a nested send' do
      node = parse_source(<<-DEF).ast
        SomeObject.new(params.permit(:username, :password))
      DEF

      expect(described_class.get_root_token(node)).to eq(:SomeObject)
    end

    it 'finds the root token for a send to a self node' do
      node = parse_source(<<-DEF).ast
        self.parameter = 1
      DEF

      expect(described_class.get_root_token(node)).to eq(:self)
    end

    it 'finds the root token for a send via block pass' do
      node = parse_source(<<-DEF).ast
        some_method(&another_method)
      DEF

      expect(described_class.get_root_token(node)).to eq(:some_method)
    end

    it 'finds the root token for a send to a module' do
      node = parse_source(<<-DEF).ast
        Module::method.call(1, 2, 3)
      DEF

      expect(described_class.get_root_token(node)).to eq(:Module)
    end
  end

  context 'when looking for return values' do
    it 'finds all the explicit return values' do
      node = parse_source(<<-DEF).ast
        def some_method(arg)
          return 123 if arg.this?
          return 456 if arg.that?
        end
      DEF

      node_123 = parse_source("123").ast
      node_456 = parse_source("456").ast

      expect(described_class.get_return_values(node)).to eq([node_123, node_456])
    end

    it 'finds all the implicit return values' do
      node = parse_source(<<-DEF).ast
        def some_method(arg)
          true if arg.test?
        end
      DEF

      node_true = parse_source("true").ast

      expect(described_class.get_return_values(node)).to eq([node_true])
    end

    it 'finds all the implicit and explicit return values' do
      node = parse_source(<<-DEF).ast
        def some_method(arg)
          return 123 if arg.this?
          return 456 if arg.that?

          789
        end
      DEF

      node_123 = parse_source("123").ast
      node_456 = parse_source("456").ast
      node_789 = parse_source("789").ast

      expect(described_class.get_return_values(node)).to eq([node_123, node_456, node_789])
    end

    it 'finds a compound statement return value' do
      node = parse_source(<<-DEF).ast
        def some_method
          self.size + 1
        end
      DEF

      node_add = parse_source("self.size + 1").ast

      expect(described_class.get_return_values(node)).to eq([node_add])
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

      expect(described_class.get_extracted_parameters(node, param_aliases: [:create_params])).to eq([:user_id])
    end
  end
end
