class RenameGroupToGroupIdOnMarchexCallRecord < ActiveRecord::Migration
  def change
    rename_column :marchex_call_records, :group, :group_id
  end
end
