require 'spec_helper'

describe RuboCop::Cop::Betterment::VagueSerialize, :config do
  let(:offense) { "Active Record models with serialized columns should specify which deserializer to use instead of falling back to the default." }

  context 'defining a class with a serialized column' do
    it 'registers an offense if there is no deserializer' do
      expect_offense(<<-RUBY)
        class Cat < ActiveRecord::Base
          serialize :attributes
          ^^^^^^^^^^^^^^^^^^^^^ #{offense}
        end
      RUBY
    end

    it 'does not register an offense if there is a deserializer' do
      expect_no_offenses(<<-RUBY)
        class Cat < ActiveRecord::Base
          serialize :attributes, Array
        end
      RUBY
    end
  end
end
