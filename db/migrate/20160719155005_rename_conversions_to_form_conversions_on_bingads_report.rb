class RenameConversionsToFormConversionsOnBingadsReport < ActiveRecord::Migration
  def change
    rename_column :bingads_reports, :conversions, :form_conversions
  end
end
