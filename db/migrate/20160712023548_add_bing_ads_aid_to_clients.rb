class AddBingAdsAidToClients < ActiveRecord::Migration
  def change
    add_column :clients, :bing_ads_aid, :string
  end
end
