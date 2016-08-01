class AddQueryClicksToAdwordsReport < ActiveRecord::Migration
  def change
    add_column :adwords_reports, :query_clicks, :hstore
  end
end
