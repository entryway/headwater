Headwater::Application.routes.draw do
  devise_for :users

  resources :projects do
    resources :stories
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
