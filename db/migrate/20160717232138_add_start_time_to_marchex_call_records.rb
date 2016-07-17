class AddStartTimeToMarchexCallRecords < ActiveRecord::Migration
  def change
    add_column :marchex_call_records, :start_time, :datetime
  end
end
