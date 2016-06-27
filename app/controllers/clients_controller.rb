class ClientsController < ApplicationController
  # if you were to have multiple Admins / God Emperors, then
  # Customer.find(params[:customer_id] would be no bueno. Should be
  # current_user.customers.find(params[:customer_id])

  before_action :must_be_logged_in
  before_action do
    must_be :admin, :customer
  end

  def index
    if @current_user.is_admin?
      @clients = Client.all
    else
      @clients = @current_user.customer.clients
    end
  end

  def show
    if @current_user.is_admin?
      @client = Client.find(params[:id])
      @customer = @client.customer
    else
      @client = @current_user.customer.clients.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    render status: 404, text: "Client not found."
  end

  def new
    if @current_user.is_admin?
      @customer = Customer.find(params[:customer_id])
      @client = @customer.clients.build
    else
      @client = @current_user.customer.clients.build
    end
  end

  def create
    if @current_user.is_admin?
      @client = Customer.find(params[:customer_id]).clients.build(client_params)
    else
      @client = @current_user.customer.clients.build(client_params)
    end

    if @client.save
      redirect_to @client
    else
      render :new
    end
  end

  def edit
    if @current_user.is_admin?
      @client = Client.find(params[:id])
      @customer = @client.customer
    else
      @client = @current_user.customer.clients.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    render status: 404, text: "Client not found."
  end

  def update
    if @current_user.is_admin?
      @client = Client.find(params[:id])
    else
      @client = @current_user.customer.clients.find(params[:id])
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
    if @current_user.is_admin?
      @client = Client.find(params[:id])
    else
      @client = @current_user.customer.clients.find(params[:id])
    end

    @client.destroy

    if @current_user.is_admin?
      redirect_to @client.customer
    else
      redirect_to clients_path
    end
  rescue ActiveRecord::RecordNotFound
    render status: 404, text: "Client not found."
  end

  private

  def client_params
    params.require(:client).permit([:name, :login_domain])
  end
end
