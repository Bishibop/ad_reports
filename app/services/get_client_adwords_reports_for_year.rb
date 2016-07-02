class GetClientAdwordsReportsForYear

  def self.call(client)
    (1.year.ago.to_date..Date.today).each do |date|
      GetClientAdwordsReportForDay.call(client, date)
    end
  end

end
