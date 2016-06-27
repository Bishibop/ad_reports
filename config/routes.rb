Rails.application.routes.draw do

  get '/login' => "login#show"
  delete '/logout' => "auth0#logout"

  get '/auth/auth0/callback' => "auth0#callback"
  get '/auth/failure' => "auth0#failure"

  get '/api_permissions/adwords/callback' => "api_permissions#adwords_callback", as: :adwords_callback

  constraints Roles.new(:customer) do
    resources :clients, only: [:new, :create]

    get '/api_permissions' => "api_permissions#index"
    get '/api_permissions/adwords/initiate' => "api_permissions#adwords_initiate", as: :adwords_initiate
  end
  resources :clients, except: [:new, :create] do
    get '/dashboard' => "dashboards#demo", constraints: Roles.new(:admin, :customer)
  end

  resources :customers do
    constraints Roles.new(:admin) do
      resources :clients, only: [:new, :create]

      get '/api_permissions' => "api_permissions#index"
      get '/api_permissions/adwords/initiate' => "api_permissions#adwords_initiate", as: :adwords_initiate
    end
  end

  get '/dashboard' => "dashboards#demo", constraints: Roles.new(:client)

  get '/' => "customers#index", constraints: Roles.new(:admin)
  get '/' => "clients#index", constraints: Roles.new(:customer)
  root 'dashboards#demo'

end
