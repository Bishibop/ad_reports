class AddNullFalseToCallIdOfMarchexCallRecord < ActiveRecord::Migration
  def change
    change_column_null :marchex_call_records, :marchex_call_id, false
  end
end
