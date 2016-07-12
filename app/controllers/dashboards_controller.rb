class DashboardsController < ApplicationController

  before_action :authenticate, except: :demo

  def show

    # this should be pushed into the user class. something like
    # @current_user.active_client. Or maybe #role_based_client. Would be great if
    # this works the same across controllers. Otherwise...meh.
    @client = if @current_user.is_admin?
                Client.find(params[:client_id])
              elsif @current_user.is_customer?
                @current_user.customer.clients.find(params[:client_id])
              elsif @current_user.is_client?
                @current_user.client
              else
                #Do nothing
              end

    adwords_reports = @client.adwords_reports

    @metrics = AdwordsReport.metric_names.inject({}) do |memo, name|
      memo[name] = adwords_reports.map(&name)
      memo
    end

    # turn google micros units into dollars
    [:cost, :cost_per_all_conversion, :cost_per_conversion].each do |key|
      @metrics[key].map! { |cost| cost / 1000000.0 }
    end

    # add in zeros for #call_conversions as a holding metric
    @metrics[:call_conversions] = Array.new(adwords_reports.size) { |i| 0 }

    # calculate daily conversion rate
    @metrics[:conversion_rate] = @metrics[:conversions].zip(@metrics[:clicks]).map do |pair|
      (pair[0].to_f * 100 / (pair[1].nonzero? || 1)).round(2)
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
