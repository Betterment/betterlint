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
end
