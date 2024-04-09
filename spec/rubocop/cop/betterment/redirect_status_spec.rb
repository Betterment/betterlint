# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::RedirectStatus, :config do
  it 'adds an offense when redirecting without a status' do
    expect_offense(<<~RUBY)
      def create
        redirect_to '/'
        ^^^^^^^^^^^^^^^ Did you forget to specify an HTTP status code? [...]
      end

      def update
        redirect_to '/'
        ^^^^^^^^^^^^^^^ Did you forget to specify an HTTP status code? [...]
      end
    RUBY

    expect_correction(<<~RUBY)
      def create
        redirect_to '/', status: :see_other
      end

      def update
        redirect_to '/', status: :see_other
      end
    RUBY
  end

  it 'does not add offenses for valid usage' do
    expect_no_offenses(<<~RUBY)
      def index
        redirect_to '/'
      end

      def show
        redirect_to '/'
      end

      def new
        redirect_to '/'
      end

      def edit
        redirect_to '/'
      end

      def create
        redirect_to '/', status: :found
        redirect_to '/', status: :see_other
      end
    RUBY
  end
end
