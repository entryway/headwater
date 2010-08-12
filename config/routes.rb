Headwater::Application.routes.draw do
  resources :projects do
    resources :stories
  end
  resources :time_entries
end
