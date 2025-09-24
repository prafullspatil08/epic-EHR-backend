Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
namespace :api do
    namespace :v1 do
      post 'chat/ask', to: 'chat#ask'
      get 'patient', to: 'patient#patient'
      get 'patient-search', to: 'patient#patient_search'
      post 'patient-match', to: 'patient#patient_match'
      get 'patient-observation', to: 'patient#fetch_patient_observation'
      get 'patient-condition', to: 'patient#fetch_patient_condition'
      get 'bulk-kick-off', to: 'patient#bulk_kick_off'
      get 'patient-by-mrn', to: 'patient#fetch_patient_by_mrn'
    end

  

  get 'observations', to: 'epic#observations'
  get 'test', to: 'epic#test'
  get 'conditions', to: 'epic#conditions'
  get 'bulk-file-request', to: 'epic#bulk_file_request'


  # Add other endpoints as needed: bulk-export, appointments, observation, etc.
end
  # Defines the root path route ("/")
  # root "posts#index"
end
