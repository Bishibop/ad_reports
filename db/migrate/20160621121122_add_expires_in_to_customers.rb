class AddExpiresInToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :bing_ads_expires_at, :datetime
  end
end
