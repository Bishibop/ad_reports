Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    'kO0tWhIUJshfIB37j9fN15XrOPRIo8De',
    '5g2Xl9NA2-e9J4mVPM4skqM7waCL7GFOdNDPt624pW7GKPNqoy2ReMv_4eKk1i5P',
    'bishibop.auth0.com',
    callback_path: "/auth/auth0/callback"
  )
end
