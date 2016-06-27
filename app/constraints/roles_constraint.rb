class RolesConstraint

  def initialize(*roles)
    @roles = roles
  end

  #def matches?(request)
    #user = current_user(request)
    #user.present? && user.is_a?(*@roles)
  #end

  def matches?(request)
    user = current_user(request)
    user.nil? || user.is_a?(*@roles)
  end

  def current_user(request)
    if request.session[:userinfo]
      User.new(request.session[:userinfo])
    else
      nil
    end
  end

end
