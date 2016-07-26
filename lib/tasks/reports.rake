namespace :reports do

  desc "Get yesterday's and today's adwords reports and marchex call records. To be run daily."
  task request_adwords_and_marchex: :environment do

    # Some kind of hack to allow for argments
    ARGV.each {|a| task a.to_sym do ; end}
    if ARGV[1]
      number_of_days = ARGV[1].to_i - 1
    else
      number_of_days = 1
    end

    GetClientAdwordsReportsForDateRange.call(mcgeorges,
                                             number_of_days.days.ago.to_date,
                                             Date.today)
    MarchexCallRecord.get_client_records_for_period(mcgeorges,
                                                    number_of_days.days.ago.to_date,
                                                    Date.today)
  end

  def mcgeorges
    Client.find_by name: "McGeorge's Rolling Hills RV"
  end
end
