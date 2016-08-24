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
    @metrics[:average_cost_per_click] = self.cost_per(@metrics[:cost], @metrics[:clicks])
    @metrics[:cost_per_conversion] = self.cost_per(@metrics[:cost], @metrics[:conversions])
    @metrics[:click_through_rate] = self.rate(@metrics[:clicks], @metrics[:impressions])
    @metrics[:conversion_rate] = self.rate(@metrics[:conversions], @metrics[:clicks])

    # Re-key metrics hash with camelcase for conventional javascript
    self.camelize_keys!(@metrics)
  end

  def demo
    @client = Client.new({name: "Acme Corp."})
    @metrics = {}
    @metrics[:cost] = Array.new(380) { Faker::Number.between(400.0, 500.0).round(2) }
    @metrics[:impressions] = Array.new(380) { Faker::Number.between(5000, 1500) }
    @metrics[:clicks] = Array.new(380) { Faker::Number.between(200, 600) }
    @metrics[:form_conversions] = Array.new(380) { Faker::Number.between(0, 15) }
    @metrics[:call_conversions] = Array.new(380) { Faker::Number.between(0, 50) }
    @metrics[:conversions] = @metrics[:form_conversions].zip(@metrics[:call_conversions])
                                                        .map do |pair|
                                                          pair[0] + pair[1]
                                                        end
    @metrics[:average_cost_per_click] = self.cost_per(@metrics[:cost], @metrics[:clicks])
    @metrics[:cost_per_conversion] = self.cost_per(@metrics[:cost], @metrics[:conversions])
    @metrics[:click_through_rate] = self.rate(@metrics[:clicks], @metrics[:impressions])
    @metrics[:conversion_rate] = self.rate(@metrics[:conversions], @metrics[:clicks])
    @metrics[:adwords_average_position] = Array.new(380) { Faker::Number.between(1.0, 3.0).round(2) }
    @metrics[:adwords_average_cost_per_click] = Array.new(380) {Faker::Number.between(1.0, 3.0).round(2)}
    @metrics[:adwords_clicks] = Array.new(380) { Faker::Number.between(100, 300) }
    @metrics[:adwords_cost] = Array.new(380) { Faker::Number.between(200.0, 300.0).round(2) }
    @metrics[:adwords_impressions] = Array.new(380) { Faker::Number.between(2000, 8000) }
    @metrics[:adwords_form_conversions] = Array.new(380) { Faker::Number.between(0, 7) }
    @metrics[:adwords_click_through_rate] = Array.new(380) { Faker::Number.between(3.0, 7.0).round(2) }
    @metrics[:adwords_conversion_rate] = Array.new(380) { Faker::Number.between(1.0, 3.0).round(2) }
    @metrics[:bingads_average_position] = Array.new(380) { Faker::Number.between(1.0, 3.0).round(2) }
    @metrics[:bingads_average_cost_per_click] = Array.new(380) {Faker::Number.between(1.0, 3.0).round(2)}
    @metrics[:bingads_clicks] = Array.new(380) { Faker::Number.between(100, 300) }
    @metrics[:bingads_cost] = Array.new(380) { Faker::Number.between(200.0, 300.0).round(2) }
    @metrics[:bingads_impressions] = Array.new(380) { Faker::Number.between(2000, 8000) }
    @metrics[:bingads_form_conversions] = Array.new(380) { Faker::Number.between(0, 7) }
    @metrics[:bingads_click_through_rate] = Array.new(380) { Faker::Number.between(3.0, 7.0).round(2) }
    @metrics[:bingads_conversion_rate] = Array.new(380) { Faker::Number.between(1.0, 3.0).round(2) }

    self.camelize_keys!(@metrics)
  end

  def search_metrics
    @client = @current_user.client(params)
    dashboard_date_range = Date.parse(params[:start])..Date.parse(params[:end])
    render json: @client.top_search_metrics(6, dashboard_date_range)
  end

protected

  def cost_per(cost_array, metric_array)
    cost_array.zip(metric_array).map do |pair|
      if pair[1].zero?
        0.00
      else
        (pair[0] / pair[1]).round(2)
      end
    end
  end

  def rate(metric_array, other_metric_array)
    metric_array.zip(other_metric_array).map do |pair|
      if pair[1].zero?
        0.00
      else
        ((pair[0].to_f / pair[1]) * 100).round(2)
      end
    end
  end

  def camelize_keys!(snake_case_keyed_hash)
    snake_case_keyed_hash.keys.each do |key|
      snake_case_keyed_hash[key.to_s.camelize(:lower)] = snake_case_keyed_hash[key]
      snake_case_keyed_hash.delete(key)
    end
  end

end
