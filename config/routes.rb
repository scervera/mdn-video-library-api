Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Tenant registration (no subdomain required)
  get 'tenant/new', to: 'tenant_registration#new'
  post 'tenant', to: 'tenant_registration#create'

  # Tenant settings (requires subdomain)
  get 'tenant/settings', to: 'tenant_settings#edit'
  patch 'tenant/settings', to: 'tenant_settings#update'

  # Dynamic branding CSS
  get 'branding.css', to: 'branding#css'

  # API Routes - Version 1 (new versioned endpoints)
  namespace :api do
    namespace :v1 do
      # Authentication
      post 'auth/login'
      post 'auth/logout'
      post 'auth/register'
      get 'auth/me'
      
      # Subdomain validation (no authentication required)
      get 'subdomain_validation/check'
      
      # Tenant registration (no authentication required)
      post 'tenant_registration', to: 'tenant_registration#create'
      
      # Curricula
      resources :curricula, only: [:index, :show] do
        member do
          post :enroll
          get :enrollment_status
        end
        
        resources :chapters, only: [:index, :show] do
          member do
            post :complete
          end
          resources :lessons, only: [:index]
        end
        
        get 'user/progress', to: 'curricula/user#progress'
      end
      
      # Chapters (for backward compatibility)
      resources :chapters, only: [:index, :show] do
        member do
          post :complete
        end
        resources :lessons, only: [:index]
      end
      
      # Lessons
      resources :lessons, only: [:show] do
        member do
          post :complete
        end
        resources :bookmarks, only: [:index, :show, :create, :update, :destroy]
      end
      
      # User Progress
      namespace :user do
        get 'progress', to: 'progress#index'
        get 'progress/:curriculum_id', to: 'progress#curriculum_progress', as: :curriculum_progress
        resources :notes, only: [:index, :show, :create, :update, :destroy]
        resources :highlights, only: [:index, :show, :create, :update, :destroy]
      end
    end
  end

  # Legacy API Routes (for backward compatibility)
  namespace :api do
    # Authentication
    post 'auth/login'
    post 'auth/logout'
    post 'auth/register'
    get 'auth/me'
    
    # Curricula
    resources :curricula, only: [:index, :show] do
      member do
        post :enroll
        get :enrollment_status
      end
      
      resources :chapters, only: [:index, :show] do
        member do
          post :complete
        end
        resources :lessons, only: [:index]
      end
      
      get 'user/progress', to: 'curricula/user#progress'
    end
    
    # Chapters (for backward compatibility)
    resources :chapters, only: [:index, :show] do
      member do
        post :complete
      end
      resources :lessons, only: [:index]
    end
    
    # Lessons
    resources :lessons, only: [:show] do
      member do
        post :complete
      end
      resources :bookmarks, only: [:index, :show, :create, :update, :destroy]
    end
    
    # User Progress
    namespace :user do
      get 'progress', to: 'progress#index'
      get 'progress/:curriculum_id', to: 'progress#curriculum_progress', as: :curriculum_progress
      resources :notes, only: [:index, :show, :create, :update, :destroy]
      resources :highlights, only: [:index, :show, :create, :update, :destroy]
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
