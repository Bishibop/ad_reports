class RemoveBingExpiresAtFromCustomers < ActiveRecord::Migration
  def change
    remove_column :customers, :bing_ads_expires_at, :datetime
  end
end
