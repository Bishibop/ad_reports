class DashboardsController < ApplicationController

  before_action :authenticate, except: :demo

  def show
    @client = if @current_user.is_admin?
                Client.find(params[:client_id])
              elsif @current_user.is_customer?
                @current_user.customer.clients.find(params[:client_id])
              elsif @current_user.is_client?
                @current_user.client
              else
                #Do nothing
              end
  end

  def demo
  end

end
