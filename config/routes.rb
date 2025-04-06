# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  resources :restaurants

  resources :menus
  get '/menus/:id/items', to: 'menus#items'

  resources :menu_items, only: %i[index show create update destroy]
  post 'menu_items/:id/assign_to_menu/:menu_id', to: 'menu_items#assign_to_menu', as: 'assign_to_menu'
end
