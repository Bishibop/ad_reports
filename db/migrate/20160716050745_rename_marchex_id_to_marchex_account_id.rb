class RenameMarchexIdToMarchexAccountId < ActiveRecord::Migration
  def change
    rename_column :clients, :marchex_id, :marchex_account_id
  end
end
