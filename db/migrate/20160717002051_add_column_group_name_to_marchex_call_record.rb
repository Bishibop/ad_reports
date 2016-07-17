class AddColumnGroupNameToMarchexCallRecord < ActiveRecord::Migration
  def change
    add_column :marchex_call_records, :group_name, :string
  end
end
