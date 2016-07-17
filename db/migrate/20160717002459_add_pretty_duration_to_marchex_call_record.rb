class AddPrettyDurationToMarchexCallRecord < ActiveRecord::Migration
  def change
    add_column :marchex_call_records, :pretty_duration, :string
  end
end
