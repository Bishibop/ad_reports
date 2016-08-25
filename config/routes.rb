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

  constraints Roles.new(:admin) do
    resources :customers do
      resources :clients, only: [:new, :create]

      get '/api_permissions' => "api_permissions#index"
      get '/api_permissions/adwords/initiate' => "api_permissions#adwords_initiate", as: :adwords_initiate
    end
  end

  constraints Roles.new(:admin, :customer) do
    resources :clients, except: [:new, :create] do
      get '/dashboard' => "dashboards#show"
    end
  end

  get '/clients/:client_id/search_metrics' => "dashboards#search_metrics", as: :search_metrics
  get '/clients/:client_id/marchex_call_records' => "marchex_call_records#index", as: :marchex_calls

  constraints Roles.new(:client) do
    get '/dashboard' => "dashboards#show"
    # To catch date-linked urls for clients
    get '/clients/:client_id/dashboard', to: redirect(status: 303) { |params, request|
      "/dashboard?#{request.query_parameters.to_query}"
    }
  end

  get '/dashboard_demo' => "dashboards#demo"

  get '/' => "customers#index", constraints: Roles.new(:admin, match_logged_out: false)
  get '/' => "clients#index", constraints: Roles.new(:customer, match_logged_out: false)
  root 'static#homepage'

end
