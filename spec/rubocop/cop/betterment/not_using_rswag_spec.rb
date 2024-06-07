# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Betterment::NotUsingRswag, :config do
  it 'does not register an offense on an empty syntax tree' do
    expect_no_offenses("")
  end

  it 'registers an offense when no path is found' do
    expect_offense(<<~RUBY)
      RSpec.describe MyApiController do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{RuboCop::Cop::Betterment::NotUsingRswag::MSG}
        describe 'A request spec' do
          context 'some situation' do
            it 'does something' do
              expect(true).to be_truthy
            end
          end
        end
      end
    RUBY
  end

  it 'does not register an offense for valid structure' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe MyApiController do
        path '/blogs' do
          post 'Creates a blog' do
            response '201', 'blog created' do
            end
          end
        end
      end
    RUBY
  end

  it 'registers an offense if the method and response nodes are missing' do
    expect_offense(<<~RUBY)
      RSpec.describe MyApiController do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{RuboCop::Cop::Betterment::NotUsingRswag::MSG}
        path '/blogs' do
          context 'some situation' do
            it 'does something else' do
              expect(true).to be_truthy
            end
          end
        end
      end
    RUBY
  end

  it 'registers an no offense if method and response nodes are present in parallel with non-rswag context' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe MyApiController do
        path '/blogs' do
          context 'some situation' do
            get 'fetch a blog' do
              context 'another situation' do
                response '200', 'blog fetched' do
                end
              end
            end
          end
        end

        it 'returns ok status with expected response' do
          get "/api/widgets/1"
          expect(response).to have_http_status :ok
          expect(response_json).to eq accepted_response.as_json
        end
      end
    RUBY
  end

  it 'does not register an offense for nested contexts with valid structure' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe MyApiController do
        path '/blogs' do
          context 'some situation' do
            post 'Creates a blog' do
              context 'another situation' do
                response '201', 'blog created' do
                end
              end
            end
          end
        end
      end
    RUBY
  end

  it 'registers an offense if a required node is missing even with nested contexts' do
    expect_offense(<<~RUBY)
      RSpec.describe MyApiController do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{RuboCop::Cop::Betterment::NotUsingRswag::MSG}
        path '/blogs' do
          context 'some situation' do
            post 'Creates a blog' do
              context 'another situation' do
                it 'does something else' do
                  expect(true).to be_truthy
                end
              end
            end
          end
        end
      end
    RUBY
  end

  it 'registers and offense if http method calls are happening within "it" examples' do
    expect_offense(<<~RUBY)
      RSpec.describe MyApiController do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{RuboCop::Cop::Betterment::NotUsingRswag::MSG}
        path '/blogs' do
          it 'does something else' do
            get "/api/widgets/1"
            expect(response).to have_http_status :ok
            expect(response_json).to eq accepted_response.as_json
          end
        end
      end
    RUBY
  end
end
