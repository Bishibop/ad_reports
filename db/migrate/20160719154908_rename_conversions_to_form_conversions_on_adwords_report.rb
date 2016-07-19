class RenameConversionsToFormConversionsOnAdwordsReport < ActiveRecord::Migration
  def change
    rename_column :adwords_reports, :conversions, :form_conversions
  end
end
