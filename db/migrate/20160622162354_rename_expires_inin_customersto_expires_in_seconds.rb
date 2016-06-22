class RenameExpiresIninCustomerstoExpiresInSeconds < ActiveRecord::Migration
  def change
    rename_column :customers, :adwords_expires_in, :adwords_expires_in_seconds
  end
end
