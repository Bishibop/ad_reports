class AddBingIssuedAtAndExpiresInToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :bing_ads_issued_at, :datetime
    add_column :customers, :bing_ads_expires_in_seconds, :integer
  end
end
