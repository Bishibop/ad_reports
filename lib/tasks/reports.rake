namespace :reports do

  desc "Get adwords reports and marchex call records. To be run daily."
  task daily_request: :environment do
    puts
    AdwordsReportRequest.call(mcgeorges,
                              [:metrics, :keywords, :queries],
                              4.days.ago.to_date,
                              Time.zone.today)
    MarchexCallRecord.get_client_records_for_period(mcgeorges,
                                                    4.days.ago.beginning_of_day,
                                                    Time.zone.now)
  end

  desc "Get keyword_conversions for all Adwords reports."
  task request_all_search_metrics: :environment do
    puts
    AdwordsReportRequest.call(mcgeorges,
                              [:keywords, :queries],
                              mcgeorges.adwords_reports.first.date,
                              Time.zone.today)

  end

  def mcgeorges
    Client.find_by name: "McGeorge's Rolling Hills RV"
  end

end
