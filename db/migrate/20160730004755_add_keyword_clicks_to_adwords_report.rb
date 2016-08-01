class AddKeywordClicksToAdwordsReport < ActiveRecord::Migration
  def change
    enable_extension "hstore"
    add_column :adwords_reports, :keyword_clicks, :hstore
  end
end
