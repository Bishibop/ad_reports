class CreateMarchexCallRecords < ActiveRecord::Migration
  def change
    create_table :marchex_call_records do |t|
      t.datetime :time
      t.string :playback_url
      t.string :classification
      t.string :status
      t.integer :duration
      t.string :phone_number
      t.string :campaign
      t.string :caller_name
      t.string :group

      t.timestamps null: false
    end
  end
end
