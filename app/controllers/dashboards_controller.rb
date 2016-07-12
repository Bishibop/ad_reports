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

    adwords_reports = @client.adwords_reports.where(date: 1.year.ago.to_date..Date.today)
    bingads_reports = @client.bingads_reports.where(date: 1.year.ago.to_date..Date.today)

    adwords_metrics = AdwordsReport.metric_names.inject({}) do |memo, name|
      memo[name] = adwords_reports.map(&name)
      memo
    end
    bingads_metrics = BingadsReport.metric_names.inject({}) do |memo, name|
      memo[name] = bingads_reports.map(&name)
      memo
    end

    # turn adwords micros units into dollars
    [:cost, :cost_per_all_conversion, :cost_per_conversion].each do |key|
      adwords_metrics[key].map! { |cost| (cost / 1000000.0).round(2) }
    end

    # zip sum base metrics
    @metrics = [:cost, :impressions, :clicks, :conversions].inject({}) do |memo, name|
      memo[name] = adwords_metrics[name].zip(bingads_metrics[name]).map do |pair|
        pair[0] + pair[1]
      end
      memo
    end

    # For some reason the costs had the whole float bullshit. I think from the
    # previous addition (of two floats)
    @metrics[:cost].map! {|cost| cost.round(2)}

    # calculate meta metrics from base metrics
    @metrics[:average_cost_per_click] = @metrics[:cost].zip(@metrics[:clicks]).map do |pair|
      if pair[1].zero?
        0.00
      else
        (pair[0] / pair[1]).round(2)
      end
    end
    @metrics[:cost_per_conversion] = @metrics[:cost].zip(@metrics[:conversions]).map do |pair|
      if pair[1].zero?
        0.00
      else
        (pair[0] / pair[1]).round(2)
      end
    end
    @metrics[:click_through_rate] = @metrics[:clicks].zip(@metrics[:impressions]).map do |pair|
      if pair[1].zero?
        0.00
      else
        ((pair[0].to_f / pair[1]) * 100).round(2)
      end
    end
    @metrics[:conversion_rate] = @metrics[:conversions].zip(@metrics[:clicks]).map do |pair|
      #(pair[0].to_f * 100 / (pair[1].nonzero? || 1)).round(2)
      if pair[1].zero?
        0.00
      else
        ((pair[0].to_f / pair[1]) * 100).round(2)
      end
    end

    # add in zeros for #call_conversions as a holding metric
    @metrics[:call_conversions] = Array.new(adwords_reports.size) { |i| 0 }


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
