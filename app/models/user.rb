class User

  def initialize(auth0_userinfo)
    @user_info = auth0_userinfo
  end

  def role
    @user_info['extra']['raw_info']['role']
  end

  def is_admin?
    self.role == 'admin'
  end

  def is_customer?
    self.role == 'customer'
  end

  def is_client?
    self.role == 'client'
  end

  def is_a? *roles
    roles.map(&:to_s).include? self.role
  end

  def customer
    if self.is_customer?
      Customer.find(@user_info['extra']['raw_info']['customerId'])
    else
      raise 'Access Error'
    end
  end

  def client
    if self.is_client?
      Customer.find(@user_info['extra']['raw_info']['clientId'])
    else
      raise 'Access Error'
    end
  end

end
