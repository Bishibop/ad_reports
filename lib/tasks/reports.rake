namespace :reports do
  desc "Get yesterday's and today's adwords reports. To be run daily."
  task request_two_day_adwords: :environment do
    GetClientAdwordsReportsForDateRange.call(mcgeorges, Date.yesterday, Date.today)
  end

  desc "Get yesterday's and today's marchex call records. To be run daily."
  task request_two_day_marchex: :environment do
    MarchexCallRecord.get_client_records_for_period(mcgeorges, Date.yesterday, Date.today)
  end

  desc "Get yesterday's and today's adwords reports and marchex call records. To be run daily."
  task request_two_day_adwords_and_marchex: [:request_two_day_adwords, :request_two_day_marchex]

  def mcgeorges
    Client.find_by name: "McGeorge's Rolling Hills RV"
  end
end
