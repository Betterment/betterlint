# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::Timeout, :config do
  context 'when using a different class than Timeout' do
    it 'does not register an offense' do
      expect_no_offenses('SomethingElse.timeout(arg1)')
    end
  end

  context 'when using the Timeout class' do
    context 'when using a different method than timeout' do
      it 'does not register an offense' do
        expect_no_offenses('Timeout.somethingElse(arg1)')
      end
    end

    context 'when using the timeout method' do
      context 'when using no args' do
        it 'does not register an offense' do
          expect_no_offenses('Timeout.timeout')
        end
      end

      context 'when using more than 1 arg' do
        it 'does not register an offense' do
          expect_no_offenses('Timeout.timeout(arg1, arg2)')
        end
      end

      context 'when using 1 arg' do
        it 'registers an offense' do
          expect_offense(<<-RUBY)
            Timeout.timeout(arg1)
            ^^^^^^^^^^^^^^^^^^^^^ Using Timeout.timeout without a custom exception can prevent rescue blocks from executing
          RUBY
        end
      end
    end
  end
end
