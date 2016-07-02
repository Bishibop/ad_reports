class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer :cost
      t.integer :impressions
      t.float :click_through_rate
      t.integer :clicks
      t.integer :all_conversions
      t.float :all_conversion_rate
      t.integer :cost_per_all_conversion
      t.integer :conversions
      t.float :conversion_rate
      t.integer :cost_per_conversions
      t.integer :average_cost_per_click
      t.float :average_position
      t.references :client, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
