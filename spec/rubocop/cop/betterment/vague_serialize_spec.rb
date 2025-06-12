# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::VagueSerialize, :config do
  let(:offense) do
    "Active Record models with serialized columns should specify which deserializer to use instead of falling back to the default.[...]"
  end

  context 'defining a class with a serialized column' do
    it 'registers an offense if there is no deserializer' do
      expect_offense(<<-RUBY)
        class Cat < ActiveRecord::Base
          serialize :attributes
          ^^^^^^^^^^^^^^^^^^^^^ #{offense}
        end
      RUBY
    end

    it 'registers an offense if there is no deserializer specified with the coder arg' do
      expect_offense(<<-RUBY)
        class Cat < ActiveRecord::Base
          serialize :attributes, type: MyType
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{offense}
        end
      RUBY
    end

    it 'registers an offense if a deserializer is specified with both positional args and kwargs' do
      expect_offense(<<-RUBY)
        class Cat < ActiveRecord::Base
          serialize :attributes, Array, coder: Array
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{offense}
        end
      RUBY

      expect_offense(<<-RUBY)
        class Cat < ActiveRecord::Base
          serialize :attributes, Array, type: MyType, coder: Array
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{offense}
        end
      RUBY
    end

    it 'does not register an offense if there is a deserializer' do
      expect_no_offenses(<<-RUBY)
        class Cat < ActiveRecord::Base
          serialize :attributes, Array
        end
      RUBY

      expect_no_offenses(<<-RUBY)
        class Cat < ActiveRecord::Base
          serialize :attributes, coder: Array
        end
      RUBY

      expect_no_offenses(<<-RUBY)
        class Cat < ActiveRecord::Base
          serialize :attributes, type: Array, coder: Array
        end
      RUBY
    end
  end
end
