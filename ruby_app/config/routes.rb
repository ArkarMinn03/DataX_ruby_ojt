Rails.application.routes.draw do
  resources :users

  namespace :api do
    resources :users
  end

  resources :events do
    resources :event_guests
  end

  get 'auth/:provider/callback', to: "sessions#googleAuth"
  get 'auth/failure', to: redirect('/')
  delete 'disconnect_google/:id', to: "sessions#disconnect"

  # get 'auth/google_oauth2', to: redirect('/auth/google_oauth2')

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
