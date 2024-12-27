require 'sidekiq/web'

Rails.application.routes.draw do
  resources :devices do
    resources :image_groups
  end

  # TODO: remove as only for test purpose
  resources :images

  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  mount Sidekiq::Web => '/sidekiq' # Sidekiq web interface at /sidekiq

  # Defines the root path route ("/")
  # root "posts#index"
end
