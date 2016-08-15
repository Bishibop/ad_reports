class Roles

  def initialize(*roles)
    @roles = roles
  end

  #def matches?(request)
    #user = current_user(request)
    #user.present? && user.authorized_for?(*@roles)
  #end

  def matches?(request)
    user = current_user(request)
    # We match on nil? to allow logged out users to match the url and then get
    # bounced to authentication in the controller. Otherwise, they would just
    # get a "no route" error for pages they should be able to go to.
    user.nil? || user.authorized_as?(*@roles)
  end

  def current_user(request)
    if request.session[:userinfo]
      User.new(request.session[:userinfo])
    else
      nil
    end
  end

end
