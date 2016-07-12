class ClientsController < ApplicationController
  # if you were to have multiple Admins / God Emperors, then
  # Customer.find(params[:customer_id] would be no bueno. Should be
  # current_user.customers.find(params[:customer_id])

  before_action :authenticate
  before_action do
    authorized_for :admin, :customer
  end

  def index
    @clients = if @current_user.is_admin?
                 Client.all
               else
                 @current_user.customer.clients
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
    @client = if @current_user.is_admin?
                Customer.find(params[:customer_id]).clients.build(client_params)
              else
                @current_user.customer.clients.build(client_params)
              end

    if @client.save
      redirect_to @client
    else
      @customer = Customer.find(params[:customer_id])
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
    @client = if @current_user.is_admin?
                Client.find(params[:id])
              else
                @current_user.customer.clients.find(params[:id])
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
    @client = if @current_user.is_admin?
                Client.find(params[:id])
              else
                @current_user.customer.clients.find(params[:id])
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
