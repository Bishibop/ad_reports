namespace :reports do

  desc "Get adwords reports and marchex call records. To be run daily."
  task daily_request: :environment do
    puts
    AdwordsReportRequest.call(mcgeorges,
                              [:metrics, :keywords, :queries],
                              3.days.ago.to_date,
                              Date.today)
    MarchexCallRecord.get_client_records_for_period(mcgeorges,
                                                    3.days.ago.to_date,
                                                    Date.today)
  end

  desc "Get keyword_conversions for all Adwords reports."
  task request_all_search_metrics: :environment do
    puts
    AdwordsReportRequest.call(mcgeorges,
                              [:keywords, :queries],
                              mcgeorges.adwords_reports.first.date,
                              Date.today).call

  end

  def mcgeorges
    Client.find_by name: "McGeorge's Rolling Hills RV"
  end

end
