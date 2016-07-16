class AddMarchexIdToMarchexCallRecord < ActiveRecord::Migration
  def change
    add_column :marchex_call_records, :marchex_id, :string
  end
end
