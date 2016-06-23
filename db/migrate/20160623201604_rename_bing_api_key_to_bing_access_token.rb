class RenameBingApiKeyToBingAccessToken < ActiveRecord::Migration
  def change
    rename_column :customers, :bing_ads_api_key, :bing_ads_access_token
  end
end
