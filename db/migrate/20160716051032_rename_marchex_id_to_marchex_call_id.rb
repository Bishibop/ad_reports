class RenameMarchexIdToMarchexCallId < ActiveRecord::Migration
  def change
    rename_column :marchex_call_records, :marchex_id, :marchex_call_id
  end
end
