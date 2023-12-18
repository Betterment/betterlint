# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::UnscopedFind, :config do
  let(:offense_unscoped_find) do
    <<~MSG
      Records are being retrieved directly using user input.
      Please query for the associated record in a way that enforces authorization (e.g. "trust-root chaining").

      INSTEAD OF THIS:
      Post.find(params[:post_id])

      DO THIS:
      current_user.posts.find(params[:post_id])

      See here for more information on this error:
      https://github.com/Betterment/betterlint/blob/main/README.md#bettermentunscopedfind
    MSG
  end

  context 'when searching for records' do
    it 'registers an offense when using user input' do
      inspect_source(<<~RUBY)
        class Application
          def create
            # find all Secret records matching a particular secret_id
            Secret.find(params[:secret_id])
            Secret.find_by(user: params[:user_id])
          end
        end
      RUBY

      expect(cop.offenses.size).to be(2)
      expect(cop.offenses.map(&:line)).to eq([4, 5])
      expect(cop.highlights.uniq).to eq(['Secret.find(params[:secret_id])', 'Secret.find_by(user: params[:user_id])'])
      expect(cop.messages.uniq).to eq([offense_unscoped_find])
    end

    it 'registers an offense when using user input wrapped by a method' do
      inspect_source(<<~RUBY)
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
            Secret.find_by(user: find_params[:user_id])
          end
        end
      RUBY

      expect(cop.offenses.size).to be(2)
      expect(cop.offenses.map(&:line)).to eq([12, 13])
      expect(cop.highlights.uniq).to eq(['Secret.find(secret_id)', 'Secret.find_by(user: find_params[:user_id])'])
      expect(cop.messages.uniq).to eq([offense_unscoped_find])
    end

    it 'registers an offense when passing user input to a custom scope' do
      inspect_source(<<~RUBY)
        class Application
          def create
            # find all Secrets in the "active" scope
            Secret.active.find(params[:secret_id])
            Secret.active.find_by(user: params[:user_id])
          end
        end
      RUBY

      expect(cop.offenses.size).to be(2)
      expect(cop.offenses.map(&:line)).to eq([4, 5])
      expect(cop.highlights.uniq).to eq(['Secret.active.find(params[:secret_id])', 'Secret.active.find_by(user: params[:user_id])'])
      expect(cop.messages.uniq).to eq([offense_unscoped_find])
    end

    it 'registers an offense when in a GraphQL namespace with no params' do
      inspect_source(<<~RUBY)
        class Foo::GraphQL::Application
          def create
            Secret.find(1)
            Secret.find_by(user: 2)
          end
        end

        module Foo
          module Graphql
            class Application
              def create
                Secret.find(1)
                Secret.find_by(user: 2)
              end
            end
          end
        end
      RUBY

      expect(cop.offenses.size).to be(4)
      expect(cop.offenses.map(&:line)).to eq([3, 4, 12, 13])
      expect(cop.highlights.uniq).to eq(['Secret.find(1)', 'Secret.find_by(user: 2)'])
      expect(cop.messages.uniq).to eq([offense_unscoped_find])
    end

    it 'registers an offense when in a GraphQL file namespace with no params' do
      inspect_source(<<~RUBY, '/graphql/subject.rb')
        class UnscopedFindSubject
          def create
            Secret.find(1)
            Secret.find_by(user: 2)
          end
        end
      RUBY

      expect(cop.offenses.size).to be(2)
      expect(cop.offenses.map(&:line)).to eq([3, 4])
      expect(cop.highlights.uniq).to eq(['Secret.find(1)', 'Secret.find_by(user: 2)'])
      expect(cop.messages.uniq).to eq([offense_unscoped_find])
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
      cop.unauthenticated_models = temp
    end
  end
end
