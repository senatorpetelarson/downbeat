Rails.application.routes.draw do
  devise_for :users, 
             path: '',
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               registration: 'signup'
             },
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations'
             }

  namespace :api do
    namespace :v1 do
      resources :clients do
        member do
          delete :remove_logo
        end
      end
      
      resources :time_entries do
        collection do
          get :active
        end
        member do
          post :forgot_stop
        end
      end
      
      resources :asana_workspaces, only: [:index, :create] do
        member do
          post :sync_projects
        end
      end
      
      resources :asana_projects, only: [:index] do
        member do
          patch :map_to_client
        end
        resources :asana_tasks, only: [:index]
      end
      
      get 'reports/monthly', to: 'reports#monthly'
    end
  end
  
  # Asana OAuth callback
  get 'auth/asana/callback', to: 'asana_auth#callback'

  # Sidekiq web UI (optional, for monitoring jobs)
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq' # Visit http://localhost:3001/sidekiq
end
