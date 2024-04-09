# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::RenderStatus, :config do
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

  it 'does not add offenses for valid usage' do
    expect_no_offenses(<<~RUBY)
      def index
        render :new
      end

      def show
        render :new
      end

      def new
        render :new
      end

      def edit
        render :new
      end

      def create
        render plain: "OK", status: :ok
        render :new, status: :unprocessable_entity
      end
    RUBY
  end
end
