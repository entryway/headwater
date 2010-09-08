Headwater::Application.routes.draw do
  devise_for :users

  resource :dashboard

  resources :users
  resource :account, :controller => 'Account'
  
  namespace :manage do
    resources :users
  end

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
  
  root :to => "dashboards#show"
end
