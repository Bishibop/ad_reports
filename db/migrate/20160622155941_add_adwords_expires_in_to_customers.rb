class AddAdwordsExpiresInToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :adwords_expires_in, :integer
  end
end
