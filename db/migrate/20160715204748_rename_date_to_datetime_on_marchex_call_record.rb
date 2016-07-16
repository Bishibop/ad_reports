class RenameDateToDatetimeOnMarchexCallRecord < ActiveRecord::Migration
  def change
    rename_column :marchex_call_records, :time, :datetime
  end
end
