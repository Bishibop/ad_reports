class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :assign_current_user

  private

  def assign_current_user
    @current_user = User.new(session[:userinfo])
  end

  def logged_in_using_omniauth?
    unless session[:userinfo].present?
      redirect_to '/login'
    end
  end

  def authorized_for(*roles)
    unless roles.include? @current_user.role
      render status: 404, text: "Page not found"
    end
  end

end
