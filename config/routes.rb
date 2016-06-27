Rails.application.routes.draw do

  get '/login' => "login#show"
  delete '/logout' => "auth0#logout"

  get '/auth/auth0/callback' => "auth0#callback"
  get '/auth/failure' => "auth0#failure"

  get '/api_permissions/adwords/callback' => "api_permissions#adwords_callback", as: :adwords_callback

  constraints RolesConstraint.new(:customer) do
    resources :clients, only: [:new, :create]

    get '/api_permissions' => "api_permissions#index"
    get '/api_permissions/adwords/initiate' => "api_permissions#adwords_initiate", as: :adwords_initiate
  end
  resources :clients, except: [:new, :create]

  resources :customers do
    constraints RolesConstraint.new(:admin) do
      resources :clients, only: [:new, :create]

      get '/api_permissions' => "api_permissions#index"
      get '/api_permissions/adwords/initiate' => "api_permissions#adwords_initiate", as: :adwords_initiate
    end
  end

  get '/dashboard' => "dashboards#netsearch_demo"

  get '/' => "customers#index", constraints: RolesConstraint.new(:admin)
  get '/' => "clients#index", constraints: RolesConstraint.new(:customer)
  root 'dashboards#netsearch_demo'

end
