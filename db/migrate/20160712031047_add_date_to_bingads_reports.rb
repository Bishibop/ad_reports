class AddDateToBingadsReports < ActiveRecord::Migration
  def change
    add_column :bingads_reports, :date, :date, null: false
  end
end
