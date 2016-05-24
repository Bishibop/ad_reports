class ClientsController < ApplicationController
  def index
    @clients = Client.all
  end

  def show
    @client = Client.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render status: 404, text: "Client not found."
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      redirect_to @client
    else
      render :new
    end
  end

  def edit
    @client = Client.find(params[:id])
  end

  def update
    @client = Client.find(params[:id])
    if @client.update(client_params)
      redirect_to @client
    else
      render :edit
    end
  end

  def destroy
  end

  private

  def client_params
    params.require(:client).permit([:name])
  end
end
