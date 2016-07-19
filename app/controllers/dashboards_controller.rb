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

    # Get your ad reports
    dashboard_date_range = 1.year.ago.ago(1.day).to_date..Date.today
    adwords_reports = @client.adwords_reports.where(date: dashboard_date_range)
    bingads_reports = @client.bingads_reports.where(date: dashboard_date_range)
    # You need to add a limit here on how many records you pick out.
    marchex_records = @client.marchex_call_records.to_a
    # All Calls
    grouped_marchex_records = marchex_records.group_by{ |r| r.start_time.in_time_zone("Eastern Time (US & Canada)").to_date }
    #grouped_marchex_records = marchex_records.uniq{|r| r.phone_number}
                                                    #.group_by{|r| r.start_time.in_time_zone("Eastern Time (US & Canada)").to_date}

    # Remaps 
    #date_totalled_call_conversions = Hash[grouped_marchex_records.map do |date, records|
      #[date, records.count]
    #end]

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
    [:cost, :cost_per_all_conversion, :cost_per_conversion].each do |key|
      adwords_metrics[key].map! { |cost| (cost / 1000000.0).round(2) }
    end

    # Zip sum base metrics over Adwords and Bing
    @metrics = [:cost, :impressions, :clicks, :form_conversions].inject({}) do |memo, name|
      memo[name] = adwords_metrics[name].zip(bingads_metrics[name]).map do |pair|
        pair[0] + pair[1]
      end
      memo
    end

    # Adds in the marchex call leads
    @metrics[:call_conversions] = dashboard_date_range.map do |date|
      grouped_marchex_records.fetch(date, []).count
    end

    # zip sums total conversions
    @metrics[:conversions] = @metrics[:form_conversions].zip(@metrics[:call_conversions])
                                                        .map do |pair|
                                                          pair[0] + pair[1]
                                                        end

    # Clear out float tails on the cost metric
    @metrics[:cost].map! {|cost| cost.round(2)}

    # Calculate meta metrics from base metrics
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

end
