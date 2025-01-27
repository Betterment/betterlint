# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::NonStandardActions, :betterlint_config do
  context 'when defining routes containing non standard actions' do
    it 'registers offences' do
      expect_offense(<<~RUBY)
        Rails.application.routes.draw do
          # OK
          resource :status, only: :show
          resources :messages, only: [:index,:show,:create]
          get :signup, to: 'signups#show'
          get 'old_summary', to: redirect('/summary', status: 302)
          resources :users do
            get 'messages', to: 'user_messages#show', as: :user_messages
          end
          resource :react_app, controller: 'react_app', only: [] do
            get '', action: :show
            get '/*path', action: :show
          end

          # NOT OK
          resources :items, only: :index do
            get 'total', on: :member
            ^^^^^^^^^^^^^^^^^^^^^^^^ Route goes to a non-standard controller action[...]
          end
          resource :splash, only: [:show, :dismiss]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Resource route refers to a non-standard action[...]
          get 'summary', to: 'pages#summary'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Route goes to a non-standard controller action[...]
        end
      RUBY
    end
  end

  context 'when not defining routes' do
    it 'does not register offences' do
      expect_no_offenses(<<~RUBY)
        def my_method
          get :value
        end
      RUBY
    end
  end

  context 'when configuring the allowed actions list' do
    let(:cop_config) do
      {
        'AdditionalAllowedActions' => %w(update_all destroy_all),
      }
    end

    it 'will allow those actions instead of the default list' do
      expect_no_offenses(<<~RUBY)
        Rails.application.routes.draw do
          resources :messages, only: [:index, :create, :destroy, :destroy_all]
        end
      RUBY
    end
  end
end
