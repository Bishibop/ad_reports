class Auth0Controller < ApplicationController
  def callback
    # This stores all the user information that came from Auth0 and the IdP
    session[:userinfo] = request.env['omniauth.auth']

    # Redirect to the URL you want after successful auth
    # This is where you would "redirect to where you came from" but that's not
    # working
    redirect_to :dashboard
  end

  def failure
    # show a failure page or redirect to an error page
    @error_msg = request.params['message']
    redirect_to :login
  end

  def logout
    session.delete(:userinfo)
    redirect_to "https://#{ENV['AUTH0_DOMAIN']}/v2/logout?returnTo=#{ENV['AUTH0_CALLBACK_PROTOCOL']}://#{ENV['HTTP_HOST']}"
  end
end
