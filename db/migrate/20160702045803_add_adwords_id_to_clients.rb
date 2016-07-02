class AddAdwordsIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :adwords_cid, :string
  end
end
