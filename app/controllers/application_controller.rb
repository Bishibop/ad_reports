class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :assign_current_user

  def current_user
    if session[:userinfo]
      User.new(session[:userinfo])
    else
      nil
    end
  end

  private

  def assign_current_user
    @current_user = current_user
  end

  def logged_in_using_omniauth?
    if session[:userinfo].present?
      # Let them through / Do nothing
    else
      session[:login_referer_path] = request.fullpath
      redirect_to '/login'
    end
  end

  def must_be(*roles)
    unless @current_user.is_a? *roles
      render status: 403, text: "Access Denied"
    end
  end

end
