# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Betterment::SpecHelperRequiredOutsideSpecDir, :config do
  def buffer_name(path)
    File.join(Pathname.pwd, path)
  end

  it 'registers an offense when rails_helper is required outside of a spec/ directory' do
    expect_offense(<<-RUBY, buffer_name('app/models/user_spec.rb'))
      require 'rails_helper'
      ^^^^^^^^^^^^^^^^^^^^^^ Spec helper required outside of a spec/ directory.
    RUBY
  end

  it 'registers an offense when spec_helper is required outside of a spec/ directory' do
    expect_offense(<<-RUBY, buffer_name('app/models/user_spec.rb'))
      require 'spec_helper'
      ^^^^^^^^^^^^^^^^^^^^^ Spec helper required outside of a spec/ directory.
    RUBY
  end

  it 'registers no offense when rails_helper is required within a spec/ directory' do
    expect_no_offenses(<<-RUBY, buffer_name('spec/models/user_spec.rb'))
      require 'rails_helper'
    RUBY
  end

  it 'registers no offense when spec_helper is required within a spec/ directory' do
    expect_no_offenses(<<-RUBY, buffer_name('spec/models/user_spec.rb'))
      require 'spec_helper'
    RUBY
  end
end
