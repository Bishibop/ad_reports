Rails.application.routes.draw do

  get '/auth/auth0/callback' => "auth0#callback"

  get '/auth/failure' => "auth#failure"

  get '/dashboard' => "dashboards#netsearch_demo"

  get '/login' => "login#show"

  resources :clients
  resources :customers

  root 'dashboards#netsearch_demo'

end
