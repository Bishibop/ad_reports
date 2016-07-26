class GetClientAdwordsReportsForDateRange

  def self.call(client, start_date, end_date)
    puts "\nGetting Adwords Reports for #{client.name} - #{start_date} to #{end_date}"
    (start_date..end_date).each do |date|
      GetClientAdwordsReportForDay.call(client, date)
    end
    puts "Adwords Reports request completed.\n\n"
  end

end
