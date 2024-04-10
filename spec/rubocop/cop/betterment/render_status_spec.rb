# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::RenderStatus, :config do
  it 'adds an offense when rendering without a status' do
    expect_offense(<<~RUBY)
      def create
        render :new
        ^^^^^^^^^^^ Did you forget to specify an HTTP status code? [...]
        render 'new'
        ^^^^^^^^^^^^ Did you forget to specify an HTTP status code? [...]
        render :other
        ^^^^^^^^^^^^^ Did you forget to specify an HTTP status code? [...]
        render 'other'
        ^^^^^^^^^^^^^^ Did you forget to specify an HTTP status code? [...]
        render plain: 'OK'
        ^^^^^^^^^^^^^^^^^^ Did you forget to specify an HTTP status code? [...]
        render(:new)
        ^^^^^^^^^^^^ Did you forget to specify an HTTP status code? [...]
        render
        ^^^^^^ Did you forget to specify an HTTP status code? [...]
        render()
        ^^^^^^^^ Did you forget to specify an HTTP status code? [...]
      end

      def update
        render :edit
        ^^^^^^^^^^^^ Did you forget to specify an HTTP status code? [...]
        render 'edit'
        ^^^^^^^^^^^^^ Did you forget to specify an HTTP status code? [...]
      end
    RUBY

    expect_correction(<<~RUBY)
      def create
        render :new, status: :unprocessable_entity
        render 'new', status: :unprocessable_entity
        render :other, status: :ok
        render 'other', status: :ok
        render plain: 'OK', status: :ok
        render(:new, status: :unprocessable_entity)
        render status: :ok
        render status: :ok
      end

      def update
        render :edit, status: :unprocessable_entity
        render 'edit', status: :unprocessable_entity
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
        render status: :ok
      end
    RUBY
  end
end
