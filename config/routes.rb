# frozen_string_literal: true

Rails.application.routes.draw do
  get 'healthcheck', to: 'healthcheck#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope ':locale',
        locale: /#{I18n.available_locales.join('|')}/ do
    scope path: 'journey_map' do
      get ':journey_map_id/:topic_identifier',
          to: 'journey_maps#show',
          as: :journey_map_topic_content
    end

    authenticated :user do
      resources :journey_items, only: %i[index create destroy]

      resources :journey_stages
      resources :topics
    end

    resources :partners
    resources :resources do
      member do
        get :download
      end
    end
  end

  root to: redirect("/#{I18n.default_locale}")
  mount BetterTogether::Engine => '/'
end
