# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::StatusCode, :config do
  it 'adds an offense when rendering without a status' do
    expect_offense(<<~RUBY)
      def create
        render :new
        ^^^^^^^^^^^ Did you forget to specify an HTTP status code? [...]
      end

      def update
        render plain: 'OK'
        ^^^^^^^^^^^^^^^^^^ Did you forget to specify an HTTP status code? [...]
      end
    RUBY

    expect_correction(<<~RUBY)
      def create
        render :new, status: :unprocessable_entity
      end

      def update
        render plain: 'OK', status: :unprocessable_entity
      end
    RUBY
  end

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
        render :new
        redirect_to '/'
      end

      def show
        render :new
        redirect_to '/'
      end

      def new
        render :new
        redirect_to '/'
      end

      def edit
        render :new
        redirect_to '/'
      end

      def create
        render plain: "OK", status: :ok
        render :new, status: :unprocessable_entity
        redirect_to '/', status: :found
        redirect_to '/', status: :see_other
      end
    RUBY
  end
end
