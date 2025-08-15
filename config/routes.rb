Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
namespace :api do
  get 'patient', to: 'epic#patient'
  get 'patient-search', to: 'epic#patient_search'
  post 'patient-match', to: 'epic#patient_match'
  get 'observations', to: 'epic#observations'
  get 'test', to: 'epic#test'
  get 'conditions', to: 'epic#conditions'

  # Add other endpoints as needed: bulk-export, appointments, observation, etc.
end
  # Defines the root path route ("/")
  # root "posts#index"
end
