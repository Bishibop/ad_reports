class GetClientAdwordsReportsForDateRange

  def self.call(client, date_range)
    date_range.each do |date|
      GetClientAdwordsReportForDay.call(client, date)
    end
  end

end
