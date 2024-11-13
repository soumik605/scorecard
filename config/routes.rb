Rails.application.routes.draw do
  root :to => "tournaments#index"
 
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :tournaments do
    member do
      get :leaderboard
    end
  end
  resources :matches
end
