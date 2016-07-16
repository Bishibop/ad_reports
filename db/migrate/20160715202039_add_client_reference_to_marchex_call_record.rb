class AddClientReferenceToMarchexCallRecord < ActiveRecord::Migration
  def change
    add_reference :marchex_call_records, :client, index: true, foreign_key: true
  end
end
