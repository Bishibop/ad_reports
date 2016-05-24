class AddCustomerToClients < ActiveRecord::Migration
  def change
    add_reference :clients, :customer, index: true, foreign_key: true
  end
end
