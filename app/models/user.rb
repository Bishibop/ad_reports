class User

  def initialize(auth0_userinfo)
    @user_info = auth0_userinfo
    @client_id = @user_info['extra']['raw_info']['clientId'] || nil
    @customer_id = @user_info['extra']['raw_info']['customerId'] || nil
    @role = @user_info['extra']['raw_info']['role']
  end

  def admin?
    @role == 'admin'
  end

  def customer?
    @role == 'customer'
  end

  def client?
    @role == 'client'
  end

  def authorized_as?(*roles)
    roles.map(&:to_s).include? @role
  end

  def customer
    if self.customer?
      Customer.find(@customer_id)
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
      Client.find(@client_id)
    else
      raise 'Access Error'
    end
  end

end
