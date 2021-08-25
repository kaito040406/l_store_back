class RenameEncryptedTelNumViColumnToLineCustomers < ActiveRecord::Migration[6.1]
  def change
    rename_column :line_customers, :encrypted_tel_num_vi, :encrypted_tel_num_iv
  end
end
