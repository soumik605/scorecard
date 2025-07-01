Rails.application.routes.draw do
  devise_for :users
  root :to => "tournaments#index"

  namespace :api, defaults: {format: 'json'}  do
    resources :players
    resources :tournaments do
      member do
        get :leaderboard
      end
    end
    resources :stats do 
      collection do 
        get :test
        get :t10
      end
    end
  end
 
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :tournaments do
    member do
      get :leaderboard
      get :head_to_head
      get :performances
      get :next_match_suggestion
      get :chart
    end
    
    collection do
      get :rivalry
      get :create_team
    end
  end
  resources :stats do 
    collection do
      get :test
      get :t10
      get :head_to_head
    end
  end
  
  resources :matches
  resources :performances
  resources :players
  resources :rankings do
    collection do 
      get :test
      get :t10
      get :solo_test
    end
  end
end
