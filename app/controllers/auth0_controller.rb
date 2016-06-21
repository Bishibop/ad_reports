class Auth0Controller < ApplicationController
  def callback
    # This stores all the user information that came from Auth0 and the IdP
    session[:userinfo] = request.env['omniauth.auth']

    # Redirect to the URL you came frome after successful auth
    login_referer_path = session[:login_referer_path]
    if login_referer_path.nil?
      redirect_to :root
    else
      session[:login_referer_path] = nil
      redirect_to login_referer_path
    end
  end

  def failure
    # show a failure page or redirect to an error page
    @error_msg = request.params['message']
    redirect_to :root
  end

  def logout
    session.delete(:userinfo)
    redirect_to "https://#{ENV['AUTH0_DOMAIN']}/v2/logout?returnTo=#{ENV['AUTH0_CALLBACK_PROTOCOL']}://#{ENV['HTTP_HOST']}"
  end
end
