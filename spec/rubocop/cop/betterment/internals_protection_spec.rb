# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::InternalsProtection, :config do
  context 'when reference is relative' do
    context 'when reference is for the same module' do
      it 'does not register offences' do
        expect_no_offenses(<<~RUBY)
          class Foo
            def my_method
               Foo::Internals::Widget.new
            end
          end
        RUBY
      end
    end

    context 'when reference is for a different module' do
      it 'registers offences' do
        expect_offense(<<~RUBY)
          class Bar
            def my_method
               Foo::Internals::Widget.new
               ^^^^^^^^^^^^^^ Internal constants may only be referenced from code within its containing module. [...]
            end
          end
        RUBY
      end
    end

    context 'when reference is to an intermediately nested module' do
      it 'does not register offences' do
        expect_no_offenses(<<~RUBY)
           class Bar::Foo
             def my_method
               Foo::Internals::Widget.new
             end
          end
        RUBY
      end
    end

    context 'when reference is to a parent module' do
      it 'does not register offences' do
        expect_no_offenses(<<~RUBY)
          class Bar::Foo
             def my_method
                Bar::Internals::Widget.new
             end
           end
        RUBY
      end
    end
  end

  context 'when reference is an absolute path' do
    context 'when reference is for the same module' do
      it 'does not register offences' do
        expect_no_offenses(<<~RUBY)
          class Foo::Bar
            def my_method
               ::Foo::Internals::Widget.new
            end
          end
        RUBY
      end
    end

    context 'when reference is for a different module' do
      it 'registers offences' do
        expect_offense(<<~RUBY)
          class Bar::Foo
            def my_method
               ::Foo::Internals::Widget.new
               ^^^^^^^^^^^^^^^^ Internal constants may only be referenced from code within its containing module. [...]
            end
          end
        RUBY
      end
    end

    context 'when defining a internals constant' do
      it 'does not register offences' do
        expect_no_offenses(<<~RUBY)
          class Foo::Bar::Internals::Widget
            def my_method
              ::Foo::Bar::Internals::OtherWidget.new
              Bar::Internals::OtherWidget.new
              Internals::OtherWidget.new
            end
          end
        RUBY
      end
    end
  end

  context 'when specifying a class_name for an ActiveRecord association' do
    context 'when reference does not include an Internals module' do
      it 'does not register offences' do
        expect_no_offenses(<<~RUBY)
          class Foo::MyRecord < ActiveRecord::Base
            has_one :widget, class_name: 'Bar::Widget'
          end
        RUBY
      end
    end

    context 'when reference is for a valid internals module' do
      it 'does not register offences' do
        expect_no_offenses(<<~RUBY)
          class Foo::MyRecord < ActiveRecord::Base
            has_one :widget, class_name: 'Foo::Internals::Widget'
            belongs_to :widget, class_name: 'Foo::Internals::Widget'
            has_many :widget, class_name: 'Foo::Internals::Widget'
          end
        RUBY
      end
    end

    context 'when reference is for an invalid internals module' do
      it 'registers an offences' do
        expect_offense(<<~RUBY)
          class Bar::MyRecord < ActiveRecord::Base
            has_one :widget, class_name: 'Foo::Internals::Widget'
                                         ^^^^^^^^^^^^^^^^^^^^^^^^ Internal constants may only be referenced from code within its containing module. [...]
            belongs_to :widget, class_name: 'Foo::Internals::Widget'
                                            ^^^^^^^^^^^^^^^^^^^^^^^^ Internal constants may only be referenced from code within its containing module. [...]
            has_many :widgets, class_name: 'Foo::Internals::Widget'
                                           ^^^^^^^^^^^^^^^^^^^^^^^^ Internal constants may only be referenced from code within its containing module. [...]
          end
        RUBY
      end
    end

    context 'when reference is an absolute path for an inaccessible internals modules' do
      it 'registers an offences' do
        expect_offense(<<~RUBY)
          class Bar::Foo::MyRecord < ActiveRecord::Base
            has_one :widget, class_name: '::Foo::Internals::Widget'
                                         ^^^^^^^^^^^^^^^^^^^^^^^^^^ Internal constants may only be referenced from code within its containing module. [...]
            belongs_to :widget, class_name: '::Foo::Internals::Widget'
                                            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Internal constants may only be referenced from code within its containing module. [...]
            has_many :widgets, class_name: '::Foo::Internals::Widget'
                                           ^^^^^^^^^^^^^^^^^^^^^^^^^^ Internal constants may only be referenced from code within its containing module. [...]
          end
        RUBY
      end
    end
  end

  context 'when in a spec with a constant described class' do
    context 'when reference is valid' do
      it 'does not register offences' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe Foo::MyPublicResource do
            let!(:existing_widget) do
              Foo::Internals::Widget.create!
            end
          end
        RUBY
      end

      context 'when reference is invalid' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
          RSpec.describe Bar::MyPublicResource do
            let!(:existing_widget) do
              Foo::Internals::Widget.create!
              ^^^^^^^^^^^^^^ Internal constants may only be referenced from code within its containing module. [...]
            end
          end
        RUBY
        end
      end
    end
  end

  context 'when in a spec with a string described class' do
    context 'when reference is valid' do
      it 'does not register offences' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe 'Foo::MyPublicResource' do
            let!(:existing_widget) do
              Foo::Internals::Widget.create!
            end
          end
        RUBY
      end

      context 'when reference is invalid' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
          RSpec.describe 'Bar::MyPublicResource' do
            let!(:existing_widget) do
              Foo::Internals::Widget.create!
              ^^^^^^^^^^^^^^ Internal constants may only be referenced from code within its containing module. [...]
            end
          end
        RUBY
        end
      end
    end
  end
end
