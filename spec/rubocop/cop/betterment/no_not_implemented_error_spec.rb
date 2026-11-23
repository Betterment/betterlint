# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::NoNotImplementedError, :config do
  describe '#on_const' do
    it 'flags direct references to the built-in exception without autocorrecting' do
      expect_offense(<<~RUBY)
        raise NotImplementedError, "Subclass must implement #call"
              ^^^^^^^^^^^^^^^^^^^ Ruby reserves `NotImplementedError` for platform limitations.[...]
        fail ::NotImplementedError.new("Subclass must implement #call")
             ^^^^^^^^^^^^^^^^^^^^^ Ruby reserves `NotImplementedError` for platform limitations.[...]
        class UnsupportedOperation < Object::NotImplementedError; end
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ruby reserves `NotImplementedError` for platform limitations.[...]
      RUBY

      expect_no_corrections
    end

    it 'flags an explicit rescue of the built-in exception' do
      expect_offense(<<~RUBY)
        begin
          export
        rescue NotImplementedError
               ^^^^^^^^^^^^^^^^^^^ Ruby reserves `NotImplementedError` for platform limitations.[...]
          fallback_export
        end
      RUBY
    end

    it 'ignores other exceptions and strings' do
      expect_no_offenses(<<~RUBY)
        raise Export::UnsupportedFormatError
        raise Vendor::NotImplementedError
        raise "NotImplementedError"
      RUBY
    end
  end
end
