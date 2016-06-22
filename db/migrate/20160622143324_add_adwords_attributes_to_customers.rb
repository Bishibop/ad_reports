class AddAdwordsAttributesToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :adwords_access_token, :string
    add_column :customers, :adwords_refresh_token, :string
    add_column :customers, :adwords_expires_at, :datetime
    add_column :customers, :adwords_issued_at, :datetime
  end
end
