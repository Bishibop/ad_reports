Rails.application.routes.draw do

  get '/login' => "login#show"
  delete '/logout' => "auth0#logout"

  get '/auth/auth0/callback' => "auth0#callback"
  get '/auth/failure' => "auth0#failure"

  resources :clients, except: [:new, :create]
  constraints RolesConstraint.new(:customer) do
    resources :clients, only: [:new, :create]

    get '/api_permissions' => "api_permissions#index"
    get '/api_permissions/adwords/initiate' => "api_permissions#adwords_initiate", as: :adwords_initiate
    get '/api_permissions/adwords/callback' => "api_permissions#adwords_callback", as: :adwords_callback
  end

  resources :customers do
    constraints RolesConstraint.new(:admin) do
      resources :clients, only: [:new, :create]

      get '/api_permissions' => "api_permissions#index"
      get '/api_permissions/adwords/initiate' => "api_permissions#adwords_initiate", as: :adwords_initiate
      get '/api_permissions/adwords/callback' => "api_permissions#adwords_callback", as: :adwords_callback
    end
  end

  get '/dashboard' => "dashboards#netsearch_demo"

  get '/' => "customers#index", constraints: RolesConstraint.new(:admin)
  get '/' => "clients#index", constraints: RolesConstraint.new(:customer)
  root 'dashboards#netsearch_demo'

end
