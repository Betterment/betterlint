# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::UseGlobalStrictLoading::ByDefaultForModels, :config do
  context 'when `self.strict_loading_by_default` is set' do
    context 'when the class has no code before or after self.strict_loading_by_default' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class MyModel < ApplicationRecord
            self.strict_loading_by_default = true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not set `self.strict_loading_by_default` in ActiveRecord models.
          end
        RUBY

        # Add explicit spaces to prevent editor from stripping them on-save
        expect_correction(<<~RUBY)
          class MyModel < ApplicationRecord
          #{'  '}
          end
        RUBY
      end
    end

    context 'when the class has a comment after self.strict_loading_by_default' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class MyModel < ApplicationRecord
            self.strict_loading_by_default = true # Set to true to enable strict_loading_by_default
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not set `self.strict_loading_by_default` in ActiveRecord models.
          end
        RUBY

        expect_correction(<<~RUBY)
          class MyModel < ApplicationRecord
             # Set to true to enable strict_loading_by_default
          end
        RUBY
      end
    end

    context 'when the class has code before self.strict_loading_by_default' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class MyModel < ApplicationRecord
            self.table_name = :my_models
            self.strict_loading_by_default = true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not set `self.strict_loading_by_default` in ActiveRecord models.
          end
        RUBY

        # Add explicit spaces to prevent editor from stripping them on-save
        expect_correction(<<~RUBY)
          class MyModel < ApplicationRecord
            self.table_name = :my_models
          #{'  '}
          end
        RUBY
      end
    end

    context 'when the class has code after self.strict_loading_by_default' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class MyModel < ApplicationRecord
            self.strict_loading_by_default = true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not set `self.strict_loading_by_default` in ActiveRecord models.

            belongs_to :user
          end
        RUBY

        # Add explicit spaces to prevent editor from stripping them on-save
        expect_correction(<<~RUBY)
          class MyModel < ApplicationRecord
          #{'  '}

            belongs_to :user
          end
        RUBY
      end
    end
  end

  it 'does not register an offense when `self.strict_loading_by_default` is not set' do
    expect_no_offenses(<<~RUBY)
      class MyModel < ApplicationRecord
      end
    RUBY
  end
end
