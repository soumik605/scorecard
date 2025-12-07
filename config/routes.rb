Rails.application.routes.draw do
  root :to => "tournaments#index"

  namespace :api, defaults: {format: 'json'}  do
    resources :players
    resources :tournaments do
      member do
        get :leaderboard
        get :head_to_head
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
      get :memory
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

  namespace :auctions do
    get :players
    get :create_room
  end

  resources :rooms do
    collection do
      post :join
      post :pick
    end
  end


  get  '/auctions', to: "auctions#index"

  get  '/register', to: 'users#new'
  post '/register', to: 'users#create'

  get  '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'


end
