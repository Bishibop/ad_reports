class RemoveStartTimeFromMarchexCallRecords < ActiveRecord::Migration
  def change
    remove_column :marchex_call_records, :start_time, :time
  end
end
