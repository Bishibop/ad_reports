class Roles

  def initialize(*roles, match_logged_out: true)
    @roles = roles
    @match_logged_out = match_logged_out
  end

  def matches?(request)
    user = current_user(request)
    if @match_logged_out
      user.nil? || user.authorized_as?(*@roles)
    else
      user.present? && user.authorized_for?(*@roles)
    end
  end

  def current_user(request)
    if request.session[:userinfo]
      User.new(request.session[:userinfo])
    else
      nil
    end
  end

end
