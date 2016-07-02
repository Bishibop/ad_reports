require 'adwords_api'

class GetClientAdwordsReportForDay

  def self.call(client, date)

    customer = client.customer

    adwords = AdwordsApi::Api.new({
      :authentication => {
          :method => 'OAuth2',
          :oauth2_client_id => ENV['ADWORDS_CLIENT_ID'],
          :oauth2_client_secret => ENV['ADWORDS_CLIENT_SECRET'],
          :oauth2_access_type => 'offline',
          :developer_token => ENV['ADWORDS_DEVELOPER_TOKEN'],
          :user_agent => 'Icarus Reporting',
          :oauth2_token => {
            access_token: customer.adwords_access_token,
            refresh_token: customer.adwords_refresh_token,
            issued_at: customer.adwords_issued_at,
            expires_in: customer.adwords_expires_in_seconds
          }
      },
      :service => {
        :environment => 'PRODUCTION'
      },
      :connection => {
        :enable_gzip => false
      },
      :library => {
        :log_level => 'INFO'
      }
    })

    report_utils = adwords.report_utils(:v201605)

    report_definition = {
      selector: {
        fields: [
          'Cost',
          'Impressions',
          'Ctr',
          'Clicks',
          'AllConversions',
          'AllConversionRate',
          'CostPerAllConversion',
          'Conversions',
          'ConversionRate',
          'CostPerConversion',
          'AverageCpc',
          'AveragePosition'
        ],
        date_range: {
          min: date.strftime("%Y%m%d"),
          max: date.strftime("%Y%m%d")
        }
      },
      report_name: "#{customer.name} summary report - #{date}",
      report_type: 'ACCOUNT_PERFORMANCE_REPORT',
      download_format: 'CSV',
      date_range_type: "CUSTOM_DATE"
    }

    adwords.skip_report_header = true
    adwords.skip_column_header = true
    adwords.skip_report_summary = true
    adwords.include_zero_impressions = true

    csv_report = report_utils.download_report(report_definition, client.adwords_cid)

    CSV::Converters[:percent_to_float] = lambda do |field|
      if field.match(/^[\d\.]*%$/)
        field.chomp('%').to_f
      else
        field
      end
    end

    report_array = CSV.parse(csv_report, converters: [:numeric, :percent_to_float])[0]

    metric_names = [ :cost,
                     :impressions,
                     :click_through_rate,
                     :clicks,
                     :all_conversions,
                     :all_conversion_rate,
                     :cost_per_all_conversion,
                     :conversions,
                     :conversion_rate,
                     :cost_per_conversion,
                     :average_cost_per_click,
                     :average_position ]

    report_attributes = metric_names.zip(report_array).to_h

    existing_report = client.reports.find_by(date: date)

    if existing_report.nil?
      client.reports.create(source: "adwords", date: date, **report_attributes)
    else
      existing_report.update(report_attributes)
      existing_report
    end

  end

end
