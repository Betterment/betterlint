# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::SimpleDelegator, :config do
  it 'does not report an offense when the class does not inherit from SimpleDelegator' do
    expect_no_offenses(<<~RUBY)
      class EntityPresenter < ComplexDelegator
      end
    RUBY
  end

  it 'does report an offense when the class inherits from SimpleDelegator' do
    expect_offense(<<~RUBY)
      class EntityPresenter < SimpleDelegator
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ In order to specify a set of explicitly available methods[...]
      end
    RUBY
  end
end
