# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  namespace :admin do
    resources :orders, only: %i[index show update]
  end
  root to: 'products#index'
  resources :orders, only: %i[index show]
  resource :cart, only: %i[show] do
    resources :orders, only: %i[new create]
  end
  # %iは中身中身をシンボルの配列にしてくれる[:create, :update, :destroy]のようになる
  resources :cart_items, only: %i[create update destroy]
  # ユーザー側：公開商品の一覧
  resources :products, only: [:index]

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      get 'health', to: 'health#index'
    end

    namespace :v2 do
      get 'health', to: 'health#index'
    end
  end

  # 店舗側：商品 CRUD
  namespace :admin do
    resources :stores, only: [] do
      resources :products
    end
  end
end
