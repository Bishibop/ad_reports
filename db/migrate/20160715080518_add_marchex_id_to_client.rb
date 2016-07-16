class AddMarchexIdToClient < ActiveRecord::Migration
  def change
    add_column :clients, :marchex_id, :string
  end
end
