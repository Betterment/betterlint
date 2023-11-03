# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::Utils::MethodReturnTable do
  context 'when processing a class' do
    it 'tracks methods with a single return value' do
      described_class.populate_index(parse_source(
        <<~SRC,
          class TestController
            def cool_number
              1337
            end
          end
        SRC
      ).ast)

      node_1337 = parse_source('1337').ast

      expect(described_class.has_method?(:cool_number)).to be(true)
      expect(described_class.get_method(:cool_number)).to eq([node_1337])
    end

    it 'tracks methods with multiple return values' do
      described_class.populate_index(parse_source(
        <<~SRC,
          class TestController
            def cool_number
              if @imaginary == 4
                123
              elsif @imaginary == 10
                456
              else
                789
              end
            end
          end
        SRC
      ).ast)

      node_a = parse_source('123').ast
      node_b = parse_source('456').ast
      node_c = parse_source('789').ast

      expect(described_class.has_method?(:cool_number)).to be(true)
      expect(described_class.get_method(:cool_number)).to eq([node_a, node_b, node_c])
    end

    it 'can track methods with compound return values' do
      described_class.populate_index(parse_source(
        <<~SRC,
          class TestController
            def user_id
              params.permit(:user_id)
            end

            def user_id_maybe
              if @imaginary
                {user_id: 123456}
              else
                params.permit(:user_id)
              end
            end
          end
        SRC
      ).ast)

      node_user_id = parse_source('params.permit(:user_id)').ast
      node_123456 = parse_source('{user_id: 123456}').ast

      expect(described_class.has_method?(:user_id)).to be(true)
      expect(described_class.get_method(:user_id)).to eq([node_user_id])
      expect(described_class.has_method?(:user_id_maybe)).to be(true)
      expect(described_class.get_method(:user_id_maybe)).to eq([node_123456, node_user_id])
    end
  end
end
