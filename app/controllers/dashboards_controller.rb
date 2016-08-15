class DashboardsController < ApplicationController

  before_action :authenticate, except: :demo

  def show

    @client = @current_user.client(params)

    # Get your ad reports
    dashboard_date_range = 1.year.ago.ago(1.day).to_date..Time.zone.today
    adwords_reports = @client.adwords_reports.where(date: dashboard_date_range)
    bingads_reports = @client.bingads_reports.where(date: dashboard_date_range)
    # All Calls
    @marchex_calls = @client.marchex_call_records.pluck(:start_time)

    grouped_marchex_calls = @marchex_calls.group_by do |record|
      record.to_date
    end

    # Transform those reports into metrics hashes
    adwords_metrics = AdwordsReport.metric_names.inject({}) do |memo, name|
      memo[name] = adwords_reports.map(&name)
      memo
    end
    bingads_metrics = BingadsReport.metric_names.inject({}) do |memo, name|
      memo[name] = bingads_reports.map(&name)
      memo
    end

    # Turn adwords micros-dollars into regular-dollars
    [ :cost,
      :cost_per_all_conversion,
      :cost_per_conversion,
      :average_cost_per_click ].each do |key|
      adwords_metrics[key].map! { |cost| (cost / 1000000.0).round(2) }
    end

    # Initialize your empty metrics object to pass into the javascript
    @metrics = {}

    # Pass through Adwords and Bing base metrics
    [:average_position, :average_cost_per_click, :clicks, :cost, :impressions, :form_conversions, :click_through_rate, :conversion_rate].each do |key|
      @metrics[key.to_s.prepend("adwords_")] = adwords_metrics[key]
      @metrics[key.to_s.prepend("bingads_")] = bingads_metrics[key]
    end

    # Sum Adwords and Bing base metrics
    [:cost, :impressions, :clicks, :form_conversions].each do |name|
      @metrics[name] = adwords_metrics[name].zip(bingads_metrics[name]).map do |pair|
        pair[0] + pair[1]
      end
    end

    # Add in the marchex call leads
    @metrics[:call_conversions] = dashboard_date_range.map do |date|
      grouped_marchex_calls.fetch(date, []).count
    end

    # zip sum total conversions
    @metrics[:conversions] = @metrics[:form_conversions].zip(@metrics[:call_conversions])
                                                        .map do |pair|
                                                          pair[0] + pair[1]
                                                        end

    # Clear out float tails on the cost metric
    @metrics[:cost].map! {|cost| cost.round(2)}

    # Calculate meta-metrics from base metrics
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
      if pair[1].zero?
        0.00
      else
        ((pair[0].to_f / pair[1]) * 100).round(2)
      end
    end

    # Re-key metrics hash with camelcase for conventional javascript
    @metrics.keys.each do |key|
      @metrics[key.to_s.camelize(:lower)] = @metrics[key]
      @metrics.delete(key)
    end
  end

  def demo
    @client = Client.new({name: "Acme Corp."})
    render :show
  end

  def search_metrics
    @client = @current_user.client(params)
    dashboard_date_range = Date.parse(params[:start])..Date.parse(params[:end])
    render json: @client.top_search_metrics(6, dashboard_date_range)
  end
end
