class AddRefreshTokenToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :bing_ads_refresh_token, :string
  end
end
