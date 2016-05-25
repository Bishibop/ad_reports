Rails.application.routes.draw do

  get '/auth/auth0/callback' => "auth0#callback"

  get '/auth/failure' => "auth#failure"

  get '/dashboard' => "dashboards#netsearch_demo"

  resources :clients
  resources :customers

  root 'login#show'
end
