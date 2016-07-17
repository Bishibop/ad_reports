class ChangeStartTimeFromDateTimeToTimeOnMarchexCallRecords < ActiveRecord::Migration
  def change
    change_column :marchex_call_records, :start_time, :time
  end
end
