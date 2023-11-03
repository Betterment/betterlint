# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::MemoizationWithArguments, :config do
  let(:method_name) { 'test_method' }
  let(:expected_offense) { '' }
  let(:default_offense) do
    '^^^^^^^^^^^^ Memoized method `test_method` accepts arguments, ' \
      'which may cause it to return a stale result. ' \
      'Remove memoization or refactor to remove arguments.'
  end
  let(:method_body) do
    <<~RUBY
      @test_method ||= 'yay'
      #{expected_offense}
    RUBY
  end
  let(:memoized_block_body) do
    <<~RUBY
      @test_method ||= begin
      #{expected_offense}
        :yay
      end
    RUBY
  end
  let(:method_def) do
    <<~RUBY
      def #{method_name}#{method_arguments}
      #{method_body.gsub(/^/, '  ')}
      end
    RUBY
  end

  context 'without arguments' do
    let(:method_arguments) { '' }

    it 'does not register an offense' do
      expect_no_offenses(method_def)
    end

    context 'for a class method' do
      let(:method_name) { 'self.test_method' }

      it 'does not register an offense' do
        expect_no_offenses(method_def)
      end
    end

    context 'when memoized with a block' do
      let(:method_body) { memoized_block_body }

      it 'does not register an offense' do
        expect_no_offenses(method_def)
      end
    end

    context 'for an unmemoized method' do
      let(:method_body) { 'wat!' }

      it 'does not register an offense' do
        expect_no_offenses(method_def)
      end
    end
  end

  context 'with an argument' do
    let(:method_arguments) { '(banana)' }
    let(:expected_offense) { default_offense }

    it 'registers an offense' do
      expect_offense(method_def)
    end

    context 'for a class method' do
      let(:method_name) { 'self.test_method' }

      it 'registers an offense' do
        expect_offense(method_def)
      end
    end

    context 'when memoized at the end after other lines of code' do
      let(:method_body) do
        <<~RUBY.strip
          line 1
          line 2
          @test_method ||= 'yay'
          #{expected_offense}
        RUBY
      end

      it 'registers an offense' do
        expect_offense(method_def)
      end
    end

    context 'when memoized with a block' do
      let(:method_body) { memoized_block_body }

      it 'registers an offense' do
        expect_offense(method_def)
      end
    end

    context 'for an unmemoized method' do
      let(:method_body) { 'wat!' }
      let(:expected_offense) { '' }

      it 'does not register an offense' do
        expect_no_offenses(method_def)
      end
    end
  end

  context 'with an optional argument' do
    let(:method_arguments) { '(banana = 4)' }
    let(:expected_offense) { default_offense }

    it 'registers an offense' do
      expect_offense(method_def)
    end

    context 'for a class method' do
      let(:method_name) { 'self.test_method' }

      it 'registers an offense' do
        expect_offense(method_def)
      end
    end

    context 'when memoized with a block' do
      let(:method_body) { memoized_block_body }

      it 'registers an offense' do
        expect_offense(method_def)
      end
    end

    context 'for an unmemoized method' do
      let(:method_body) { 'wat!' }
      let(:expected_offense) { '' }

      it 'does not register an offense' do
        expect_no_offenses(method_def)
      end
    end
  end

  context 'with a keyword argument' do
    let(:method_arguments) { '(banana:)' }
    let(:expected_offense) { default_offense }

    it 'registers an offense' do
      expect_offense(method_def)
    end

    context 'for a class method' do
      let(:method_name) { 'self.test_method' }

      it 'registers an offense' do
        expect_offense(method_def)
      end
    end

    context 'when memoized with a block' do
      let(:method_body) { memoized_block_body }

      it 'registers an offense' do
        expect_offense(method_def)
      end
    end

    context 'for an unmemoized method' do
      let(:method_body) { 'wat!' }
      let(:expected_offense) { '' }

      it 'does not register an offense' do
        expect_no_offenses(method_def)
      end
    end
  end

  context 'with an optional keyword argument' do
    let(:method_arguments) { '(banana: nil)' }
    let(:expected_offense) { default_offense }

    it 'registers an offense' do
      expect_offense(method_def)
    end

    context 'for a class method' do
      let(:method_name) { 'self.test_method' }

      it 'registers an offense' do
        expect_offense(method_def)
      end
    end

    context 'when memoized with a block' do
      let(:method_body) { memoized_block_body }

      it 'registers an offense' do
        expect_offense(method_def)
      end
    end

    context 'for an unmemoized method' do
      let(:method_body) { 'wat!' }
      let(:expected_offense) { '' }

      it 'does not register an offense' do
        expect_no_offenses(method_def)
      end
    end
  end

  context 'with multiple arguments' do
    let(:method_arguments) { '(foo, bar, baz:)' }
    let(:expected_offense) { default_offense }

    it 'registers an offense' do
      expect_offense(method_def)
    end

    context 'for a class method' do
      let(:method_name) { 'self.test_method' }

      it 'registers an offense' do
        expect_offense(method_def)
      end
    end

    context 'when memoized with a block' do
      let(:method_body) { memoized_block_body }

      it 'registers an offense' do
        expect_offense(method_def)
      end
    end

    context 'for an unmemoized method' do
      let(:method_body) { 'wat!' }
      let(:expected_offense) { '' }

      it 'does not register an offense' do
        expect_no_offenses(method_def)
      end
    end
  end

  context 'for initialize methods' do
    let(:method_arguments) { '(arguments = {})' }
    let(:method_name) { 'initialize' }

    it 'does not register an offense' do
      expect_no_offenses(method_def)
    end
  end
end
