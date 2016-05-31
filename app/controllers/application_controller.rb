class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def logged_in_using_omniauth?
    unless session[:userinfo].present?
      redirect_to '/login'
    end
  end

  def authorized_for(*roles)
    unless roles.include? session[:userinfo]['role']
      redirect_to '/login'
    end
  end

end
