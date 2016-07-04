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
    @reports = @client.reports

    @metrics = Report.metric_names.inject({}) do |memo, name|
      memo[name] = @reports.map(&name)
      memo
    end

    # rekey metrics hash with camelcase for conventional javascript
    @metrics.keys.each do |key|
      @metrics[key.to_s.camelize(:lower)] = @metrics[key]
      @metrics.delete(key)
    end
  end

  def demo
    @client = Client.new({name: "Acme Corp."})
    render :show
  end

end
