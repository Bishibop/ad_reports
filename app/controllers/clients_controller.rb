class ClientsController < ApplicationController
  # if you were to have multiple Admins / God Emperors, then
  # Customer.find(params[:customer_id] would be no bueno. Should be
  # @current_user.customers.find(params[:customer_id])

  before_action :logged_in_using_omniauth?
  before_action { authorized_for 'admin', 'customer' }

  def index
    if @current_user['role'] == 'admin'
      if params[:customer_id].present?
        @clients = Customer.find(params[:customer_id]).clients
      else
        @clients = Client.all
      end
    else
      @clients = Customer.find(@current_user['customer_id']).clients
    end
  end

  def show
    if @current_user['role'] == 'admin'
      @client = Client.find(params[:id])
    else
      @client = Customer.find(@current_user['customer_id']).clients.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    render status: 404, text: "Client not found."
  end

  def new
    if @current_user['role'] == 'admin'
      @client = Customer.find(params[:customer_id]).clients.build
    else
      @client = Customer.find(@current_user['customer_id']).clients.build
    end
  end

  def create
    if @current_user['role'] == 'admin'
      @client = Customer.find(params[:customer_id]).clients.build(client_params)
    else
      @client = Customer.find(@current_user['customer_id']).clients.build(client_params)
    end

    if @client.save
      redirect_to @client
    else
      render :new
    end
  end

  def edit
    if @current_user['role'] == 'admin'
      @client = Client.find(params[:id])
    else
      @client = Customer.find(@current_user['customer_id']).clients.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    render status: 404, text: "Client not found."
  end

  def update
    if @curent_user['role'] == 'admin'
      @client = Client.find(params[:id])
    else
      @client = Customer.find(@current_user['customer_id']).clients.find(params[:id])
    end

    if @client.update(client_params)
      redirect_to @client
    else
      render :edit
    end
  rescue ActiveRecord::RecordNotFound
    render status: 404, text: "Client not found."
  end

  def destroy
    if @current_user['rold'] == 'admin'
      @client = Client.find(params[:id])
    else
      @client = Customer.find(@current_user['customer_id']).clients.find(params[:id])
    end

    @client.destroy

    redirect_to clients_path
  rescue ActiveRecord::RecordNotFound
    render status: 404, text: "Client not found."
  end

  private

  def client_params
    params.require(:client).permit([:name])
  end
end
