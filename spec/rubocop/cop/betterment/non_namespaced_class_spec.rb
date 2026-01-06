# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::NonNamespacedClass, :config do
  let(:msg) do
    <<~MSG.tr("\n", " ").strip
      Do not add new classes that are not namespaced underneath another constant.
      Classes should be defined within a module namespace (e.g., `module MyNamespace; class Foo; end; end`)
      or use the `::` syntax (e.g., `class MyNamespace::Foo`).
    MSG
  end

  it 'reports non-namespaced classes' do
    expect_offense(<<~RUBY)
      class Foo
      ^^^^^^^^^ #{msg}
      end
    RUBY
  end

  it 'reports non-namespaced classes with inheritance' do
    expect_offense(<<~RUBY)
      class Foo < Bar
      ^^^^^^^^^^^^^^^ #{msg}
      end
    RUBY
  end

  it 'does not report classes inside a module' do
    expect_no_offenses(<<~RUBY)
      module MyNamespace
        class Foo
        end
      end
    RUBY
  end

  it 'does not report classes inside nested modules' do
    expect_no_offenses(<<~RUBY)
      module Outer
        module Inner
          class Foo
          end
        end
      end
    RUBY
  end

  it 'does not report classes using :: syntax' do
    expect_no_offenses(<<~RUBY)
      class MyNamespace::Foo
      end
    RUBY
  end

  it 'does not report classes using nested :: syntax' do
    expect_no_offenses(<<~RUBY)
      class Outer::Inner::Foo
      end
    RUBY
  end

  it 'does not report nested classes when outer class is in module' do
    expect_no_offenses(<<~RUBY)
      module Namespace
        class Outer
          class Inner
          end
        end
      end
    RUBY
  end

  it 'reports top-level class but not inner nested class' do
    expect_offense(<<~RUBY)
      class Outer
      ^^^^^^^^^^^ #{msg}
        class Inner
        end
      end
    RUBY
  end

  it 'reports multiple non-namespaced classes' do
    expect_offense(<<~RUBY)
      class Foo
      ^^^^^^^^^ #{msg}
      end

      class Bar
      ^^^^^^^^^ #{msg}
      end
    RUBY
  end

  it 'registers namespaced classes even with non-namespaced classes in same file' do
    expect_offense(<<~RUBY)
      class TopLevel
      ^^^^^^^^^^^^^^ #{msg}
      end

      module MyNamespace
        class Foo
        end
      end
    RUBY
  end
end
