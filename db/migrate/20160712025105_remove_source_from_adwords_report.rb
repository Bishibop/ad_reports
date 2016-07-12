class RemoveSourceFromAdwordsReport < ActiveRecord::Migration
  def change
    remove_column :adwords_reports, :source, :string
  end
end
