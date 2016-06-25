class AddNullFalseToNameAndDomainOfClients < ActiveRecord::Migration
  def change
    change_column_null :clients, :name, false
    change_column_null :clients, :login_domain, false
  end
end
