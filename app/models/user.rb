class User

  def initialize(auth0_userinfo)
    @user_info = auth0_userinfo
  end

  def role
    @user_info['extra']['raw_info']['role']
  end

  def admin?
    self.role == 'admin'
  end

  def customer?
    self.role == 'customer'
  end

  def client?
    self.role == 'client'
  end

  def authorized_as?(*roles)
    roles.map(&:to_s).include? self.role
  end

  def customer
    if self.customer?
      Customer.find(@user_info['extra']['raw_info']['customerId'])
    else
      raise 'Access Error'
    end
  end

  def client(params)
    if self.admin?
      Client.find(params[:client_id])
    elsif self.customer?
      self.customer.clients.find(params[:client_id])
    elsif self.client?
      Client.find(@user_info['extra']['raw_info']['clientId'])
    else
      raise 'Access Error'
    end
  end

end
