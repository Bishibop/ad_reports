class AddLoginDomainToClients < ActiveRecord::Migration
  def change
    add_column :clients, :login_domain, :string
  end
end
