class RemoveGroupIdFromMarchexCallRecords < ActiveRecord::Migration
  def change
    remove_column :marchex_call_records, :group_id, :string
  end
end
