Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    ENV["AUTH0_CLIENT_ID"],
    ENV["AUTH0_CLIENT_SECRET"],
    'bishibop.auth0.com',
    callback_path: ENV["AUTH0_CALLBACK_PATH"]
  )
end
