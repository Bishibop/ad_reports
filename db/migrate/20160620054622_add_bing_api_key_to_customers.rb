class AddBingApiKeyToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :bing_ads_api_key, :string
  end
end
