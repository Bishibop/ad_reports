class RenamePhoneNumberToCallerNumber < ActiveRecord::Migration
  def change
    rename_column :marchex_call_records, :phone_number, :caller_numer
  end
end
