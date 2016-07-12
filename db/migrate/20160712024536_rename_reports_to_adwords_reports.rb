class RenameReportsToAdwordsReports < ActiveRecord::Migration
  def change
    rename_table :reports, :adwords_reports
  end
end
