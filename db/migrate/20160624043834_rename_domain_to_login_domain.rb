class RenameDomainToLoginDomain < ActiveRecord::Migration
  def change
    rename_column :customers, :domain, :login_domain
  end
end
