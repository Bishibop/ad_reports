class RenameKeywordClicksToKeywordConversions < ActiveRecord::Migration
  def change
    rename_column :adwords_reports, :keyword_clicks, :keyword_conversions
  end
end
