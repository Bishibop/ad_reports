class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :assign_current_user_to_instance

  def current_user
    if session[:userinfo]
      User.new(session[:userinfo])
    else
      nil
    end
  end

private

  def assign_current_user_to_instance
    @current_user = current_user
  end

  def authenticate
    if session[:userinfo].present?
      # Let them through / Do nothing
    else
      session[:login_referer_path] = request.fullpath
      redirect_to '/login'
    end
  end

  def authorized_for(*roles)
    unless @current_user.authorized_as?(*roles)
      render status: 403, text: "Access Denied"
    end
  end

end
