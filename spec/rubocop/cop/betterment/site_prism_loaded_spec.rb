require 'spec_helper'

describe RuboCop::Cop::Betterment::SitePrismLoaded, :config do
  context 'when using be_loaded' do
    it 'does not register an offense' do
      expect_no_offenses('expect(page).to be_loaded')
    end
  end

  context 'when using be_displayed' do
    it 'registers an offense' do
      expect_offense(<<-RUBY)
        expect(page).to be_displayed
                        ^^^^^^^^^^^^ Use `be_loaded` instead of `be_displayed`
      RUBY
    end
  end

  it 'autocorrects `be_displayed` to `be_loaded` ' do
    expect(autocorrect_source('expect(page).to be_displayed')).to eq('expect(page).to be_loaded')
  end
end
