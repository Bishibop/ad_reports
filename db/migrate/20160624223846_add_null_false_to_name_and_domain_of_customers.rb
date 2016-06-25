class AddNullFalseToNameAndDomainOfCustomers < ActiveRecord::Migration
  def change
    change_column_null :customers, :name, false
    change_column_null :customers, :login_domain, false
  end
end
