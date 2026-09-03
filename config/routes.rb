# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :orders, only: %i[index show update]
    resources :order_items, only: [:update]
  end
  root to: 'home#index'
  resource :cart, only: [:show]
  # %iは中身中身をシンボルの配列にしてくれる[:create, :update, :destroy]のようになる
  resources :cart_items, only: %i[create update destroy]

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      get 'health', to: 'health#index'
    end

    namespace :v2 do
      get 'health', to: 'health#index'
    end
  end
end
