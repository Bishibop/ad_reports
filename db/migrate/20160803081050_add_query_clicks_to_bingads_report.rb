class AddQueryClicksToBingadsReport < ActiveRecord::Migration
  def change
    add_column :bingads_reports, :query_clicks, :hstore
  end
end
