class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  @current_user = session[:userinfo]

  private

  def logged_in_using_omniauth?
    unless @current_user.present?
      redirect_to '/login'
    end
  end

  def authorized_for(*roles)
    unless roles.include? @current_user['role']
      redirect_to '/login'
    end
  end

end
