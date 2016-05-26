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
  end
end
