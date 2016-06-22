class RemoveAdwordsExpiresAtFromCustomers < ActiveRecord::Migration
  def change
    remove_column :customers, :adwords_expires_at, :datetime
  end
end
