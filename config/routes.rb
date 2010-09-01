Headwater::Application.routes.draw do
  devise_for :users

  resources :users
  resource :account

  resources :projects do
    resources :stories do
      member do
        post :move
      end
    end
    resources :time_entries
  end
  
  resources :time_entries do
    collection do
      get :current
    end
    member do
      get :start
      get :pause
      get :remove
    end
  end
  
  root :to => "projects#index"
end
