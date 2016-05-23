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

  private

  def client_params
    params.require(:client).permit([:name])
  end
end
