# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::SitePrismLoaded, :config do
  context 'when using be_loaded' do
    it 'does not register an offense' do
      expect_no_offenses('expect(page).to be_loaded')
    end
  end

  context 'when using be_displayed' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        expect(page).to be_displayed
                        ^^^^^^^^^^^^ Use `be_loaded` instead of `be_displayed`
      RUBY

      expect_correction(<<~RUBY)
        expect(page).to be_loaded
      RUBY
    end
  end
end
