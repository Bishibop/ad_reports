class RenameCostPerConversionsToCostPerConversion < ActiveRecord::Migration
  def change
    rename_column :reports, :cost_per_conversions, :cost_per_conversion
  end
end
