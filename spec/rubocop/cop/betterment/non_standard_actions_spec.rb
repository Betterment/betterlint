# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::NonStandardActions, :betterlint_config do
  context 'when defining routes containing non standard actions' do
    let(:source) do
      <<-SRC
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
        end
        resource :splash, only: [:show, :dismiss]
        get 'summary', to: 'pages#summary'
      end
      SRC
    end

    it 'registers offences' do
      inspect_source(source)
      expect(cop.highlights).to contain_exactly(
        include("get 'total'"),
        include('only: [:show, :dismiss]'),
        include("to: 'pages#summary'"),
      )
    end
  end

  context 'when not defining routes' do
    let(:source) do
      <<-SRC
      def my_method
        get :value
      end
      SRC
    end

    it 'does not register offences' do
      inspect_source(source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'when configuring the allowed actions list' do
    let(:cop_config) do
      {
        'AdditionalAllowedActions' => %w(update_all destroy_all),
      }
    end
    let(:source) do
      <<-SRC
      Rails.application.routes.draw do
        resources :messages, only: [:index, :create, :destroy, :destroy_all]
      end
      SRC
    end

    it 'will allow those actions instead of the default list' do
      inspect_source(source)
      expect(cop.offenses).to be_empty
    end
  end
end
