class AddMarchexCallIdIndexToMarchexCallRecord < ActiveRecord::Migration
  def change
    add_index :marchex_call_records, [:marchex_call_id, :client_id], unique: true
  end
end
