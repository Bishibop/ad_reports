Rails.application.routes.draw do

  get '/auth/auth0/callback' => "auth0#callback"

  get '/auth/failure' => "auth0#failure"

  get '/dashboard' => "dashboards#netsearch_demo"

  get '/login' => "login#show"
  delete '/logout' => "auth0#logout"

  resources :clients
  resources :customers

  root 'dashboards#netsearch_demo'

end
