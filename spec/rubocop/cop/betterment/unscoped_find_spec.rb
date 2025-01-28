# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::UnscopedFind, :betterlint_config do
  context 'when searching for records' do
    it 'registers an offense when using user input' do
      expect_offense(<<~RUBY)
        class Application
          def create
            # find all Secret records matching a particular secret_id
            Secret.find(params[:secret_id])
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Records are being retrieved [...]
            Secret.find_by(user: params[:user_id])
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Records are being retrieved [...]
          end
        end
      RUBY
    end

    it 'registers an offense when using user input wrapped by a method' do
      expect_offense(<<~RUBY)
        class Application
          def secret_id
            params[:secret_id]
          end

          def find_params
            params.permit(:user_id)
          end

          def create
            # find all Secret records matching a particular secret_id
            Secret.find(secret_id)
            ^^^^^^^^^^^^^^^^^^^^^^ Records are being retrieved [...]
            Secret.find_by(user: find_params[:user_id])
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Records are being retrieved [...]
          end
        end
      RUBY
    end

    it 'registers an offense when passing user input to a custom scope' do
      expect_offense(<<~RUBY)
        class Application
          def create
            # find all Secrets in the "active" scope
            Secret.active.find(params[:secret_id])
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Records are being retrieved [...]
            Secret.active.find_by(user: params[:user_id])
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Records are being retrieved [...]
          end
        end
      RUBY
    end

    it 'registers an offense when in a GraphQL namespace with no params' do
      expect_offense(<<~RUBY)
        class Foo::GraphQL::Application
          def create
            Secret.find(1)
            ^^^^^^^^^^^^^^ Records are being retrieved [...]
            Secret.find_by(user: 2)
            ^^^^^^^^^^^^^^^^^^^^^^^ Records are being retrieved [...]
          end
        end

        module Foo
          module Graphql
            class Application
              def create
                Secret.find(1)
                ^^^^^^^^^^^^^^ Records are being retrieved [...]
                Secret.find_by(user: 2)
                ^^^^^^^^^^^^^^^^^^^^^^^ Records are being retrieved [...]
              end
            end
          end
        end
      RUBY
    end

    it 'registers an offense when in a GraphQL file namespace with no params' do
      expect_offense(<<~RUBY, '/graphql/subject.rb')
        class UnscopedFindSubject
          def create
            Secret.find(1)
            ^^^^^^^^^^^^^^ Records are being retrieved [...]
            Secret.find_by(user: 2)
            ^^^^^^^^^^^^^^^^^^^^^^^ Records are being retrieved [...]
          end
        end
      RUBY
    end

    it 'does not register an offense when trust chaining even with user input in graphql namespace' do
      expect_no_offenses(<<~RUBY, '/graphql/subject.rb')
        class GraphQL::Application
          def create
            current_user.secrets.find(params[:secret_id])
            current_user.secrets.active.find(params[:secret_id])
            current_user.secrets.find_by(user: params[:user_id])
            current_user.secrets.active.find_by(user: params[:user_id])
          end
        end
      RUBY
    end

    it 'does not register an offense when searching for unauthenticated models' do
      temp = cop.unauthenticated_models
      cop.unauthenticated_models = [:Post]

      # if posts is a table with strictly public content, we can add the model
      # to the list of unauthenticated models so the cop won't flag any finds
      # against it.
      expect_no_offenses(<<~RUBY)
        class Application
          def create
            Post.find(params[:post_id])
            Post.active.find(params[:post_id])
            Post.find_by(user: params[:user_id])
            Post.active.find_by(params[:post_id])
          end
        end
      RUBY
    ensure
      cop.unauthenticated_models = temp
    end
  end
end
