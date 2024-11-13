# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::InvertWhere, :config do
  let(:offense) { RuboCop::Cop::Betterment::InvertWhere::MSG }
  context 'when using invert_where method' do
    it 'registers an offense' do
      expect_offense(<<-RUBY)
        User.where(name: 'John').invert_where
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{RuboCop::Cop::Betterment::InvertWhere::MSG}
      RUBY
    end

    it 'does not register an offense for other method calls' do
      expect_no_offenses(<<-RUBY)
        User.where(name: 'John')
      RUBY
    end
  end
end
