class RenameBingAdsAidToBingadsAid < ActiveRecord::Migration
  def change
    rename_column :clients, :bing_ads_aid, :bingads_aid
  end
end
