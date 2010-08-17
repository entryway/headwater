Headwater::Application.routes.draw do
  resources :projects do
    resources :stories
  end
  resources :time_entries do
    member do
      get :start
      get :pause
      get :remove
    end
  end
  
  root :to => "projects#index"
end
