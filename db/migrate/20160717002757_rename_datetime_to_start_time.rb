class RenameDatetimeToStartTime < ActiveRecord::Migration
  def change
    rename_column :marchex_call_records, :datetime, :start_time
  end
end
