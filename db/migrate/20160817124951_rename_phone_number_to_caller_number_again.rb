class RenamePhoneNumberToCallerNumberAgain < ActiveRecord::Migration
  def change
    rename_column :marchex_call_records, :caller_numer, :caller_number
  end
end
