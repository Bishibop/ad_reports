class ClientsController < ApplicationController
  def index
  end

  def show
    @client = Client.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render status: 404, text: "Client not found."
  end

  def new
  end

  def create
    @client = Client.new(client_params)

    @client.save
    redirect_to @client
  end

  private

  def client_params
    params.require(:client).permit([:name])
  end
end
