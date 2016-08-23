require 'adwords_api'

class AdwordsReportRequest

  def self.call(client, report_types, start_date, end_date)
    @client = client
    @customer = client.customer
    @start_date = start_date
    @end_date = end_date || @start_date
    @report_types = report_types

    puts "Requesting Adwords Reports(#{@report_types.join(", ")}) for #{@client.name} - #{@start_date} to #{@end_date}"

    reports = (@start_date..@end_date).map do |date|
      report = @client.adwords_reports.find_or_initialize_by(date: date) do
        puts "\tInitialized new report."
      end

      report_attributes = @report_types.inject({}) do |attributes, report_type|
        puts "\tRequesting #{report_type} report..."

        report_definition = self.send(report_type.to_s + "_report_definition", date)

        adwords_api_connection = self.create_api_connection.tap do |connection|
          connection.skip_report_header = true
          connection.skip_column_header = true
          connection.skip_report_summary = true
          connection.include_zero_impressions = false
        end

        csv_report = adwords_api_connection
                       .report_utils(:v201605)
                       .download_report(report_definition, @client.adwords_cid)

        attributes.merge(self.send(report_type.to_s + '_csv_handler', csv_report))
      end

      report.tap do |r|
        r.update(report_attributes)
        puts "\tAdwords Reports request for #{date} completed.\n"
      end
    end
    puts "Adwords Reports request completed.\n"
    reports
  end

protected

  def self.create_api_connection
    AdwordsApi::Api.new({
      :authentication => {
          :method => 'OAuth2',
          :oauth2_client_id => ENV['ADWORDS_CLIENT_ID'],
          :oauth2_client_secret => ENV['ADWORDS_CLIENT_SECRET'],
          :oauth2_access_type => 'offline',
          :developer_token => ENV['ADWORDS_DEVELOPER_TOKEN'],
          :user_agent => 'Icarus Reporting',
          :oauth2_token => {
            access_token: @customer.adwords_access_token,
            refresh_token: @customer.adwords_refresh_token,
            issued_at: @customer.adwords_issued_at,
            expires_in: @customer.adwords_expires_in_seconds
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
  end

  def self.metrics_report_definition(date)
    { report_type: 'ACCOUNT_PERFORMANCE_REPORT',
      selector: {
        fields: [ 'Cost',
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
                  'AveragePosition' ],
        date_range: {
          min: date.strftime("%Y%m%d"),
          max: date.strftime("%Y%m%d")
        }
      },
      report_name: "#{@client.name} metrics report - #{date}",
      download_format: 'CSV',
      date_range_type: "CUSTOM_DATE" }
  end

  def self.metrics_csv_handler(csv_report)
    CSV::Converters[:percent_to_float] = lambda do |field|
      if field.match(/^[\d\.]*%$/)
        field.chomp('%').to_f
      else
        field
      end
    end

    report_array = CSV.parse(csv_report, converters: [:numeric, :percent_to_float])[0]

    # this is really fragile.
    AdwordsReport.metric_names.zip(report_array).to_h
  end

  def self.keywords_report_definition(date)
    { report_type: 'KEYWORDS_PERFORMANCE_REPORT',
      selector: {
        fields: [ 'KeywordMatchType',
                  'Criteria',
                  'Conversions' ],
        date_range: {
          min: date.strftime("%Y%m%d"),
          max: date.strftime("%Y%m%d")
        }
      },
      report_name: "#{@client.name} keyword report - #{date}",
      download_format: 'CSV',
      date_range_type: "CUSTOM_DATE" }
  end

  def self.keywords_csv_handler(csv_report)
      keyword_conversions = {}
      CSV.parse(csv_report, converters: [:numeric]) do |row|
        key = row[0][0..4] + " - " + row[1]
        keyword_conversions[key] = keyword_conversions.fetch(key, 0) + row[2]
      end
      { keyword_conversions: keyword_conversions }
  end

  def self.queries_report_definition(date)
    { report_type: 'SEARCH_QUERY_PERFORMANCE_REPORT',
      selector: {
        fields: [ 'QueryMatchTypeWithVariant',
                  'Query',
                  'Clicks' ],
        date_range: {
          min: date.strftime("%Y%m%d"),
          max: date.strftime("%Y%m%d")
        }
      },
      report_name: "#{@client.name} query report - #{date}",
      download_format: 'CSV',
      date_range_type: "CUSTOM_DATE" }
  end

  def self.queries_csv_handler(csv_report)
      query_clicks = {}
      CSV.parse(csv_report, converters: [:numeric]) do |row|
        key = row[0][0..4] + ' - ' + row[1]
        query_clicks[key] = query_clicks.fetch(key, 0) + row[2]
      end
      { query_clicks: query_clicks }
  end

end
