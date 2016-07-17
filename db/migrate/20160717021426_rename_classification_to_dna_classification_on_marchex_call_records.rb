class RenameClassificationToDnaClassificationOnMarchexCallRecords < ActiveRecord::Migration
  def change
    rename_column :marchex_call_records, :classification, :dna_classification
  end
end
