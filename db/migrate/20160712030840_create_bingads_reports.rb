class CreateBingadsReports < ActiveRecord::Migration
  def change
    create_table :bingads_reports do |t|
      t.float :cost
      t.integer :impressions
      t.float :click_through_rate
      t.integer :clicks
      t.integer :conversions
      t.float :cost_per_conversion
      t.float :average_cost_per_click
      t.float :average_position
      t.float :conversion_rate
      t.references :client, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
