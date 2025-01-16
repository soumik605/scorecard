Rails.application.routes.draw do
  namespace :api do
    get 'tournaments/index'
  end
  devise_for :users
  root :to => "tournaments#index"

  namespace :api, defaults: {format: 'json'}  do
    resources :players
    resources :tournaments, as: :tours
  end
 
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :tournaments do
    member do
      get :leaderboard
    end
  end
  resources :stats do 
    collection do
      get :head_to_head
    end
  end
  
  resources :matches
  resources :performances
  resources :players
  resources :rankings
end
