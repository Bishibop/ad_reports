class AddNullFalseToDateOfReports < ActiveRecord::Migration
  def change
    change_column_null :reports, :date, false
  end
end
