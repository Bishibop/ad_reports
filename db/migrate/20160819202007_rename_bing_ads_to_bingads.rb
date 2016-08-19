class RenameBingAdsToBingads < ActiveRecord::Migration
  def change
    rename_column :customers, :bing_ads_issued_at, :bingads_issued_at
    rename_column :customers, :bing_ads_expires_in_seconds, :bingads_expires_in_seconds
    rename_column :customers, :bing_ads_access_token, :bingads_access_token
    rename_column :customers, :bing_ads_refresh_token, :bingads_refresh_token
  end
end
