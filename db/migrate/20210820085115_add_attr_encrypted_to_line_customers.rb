class AddAttrEncryptedToLineCustomers < ActiveRecord::Migration[6.1]
  def change
    remove_column :line_customers, :address, :string
    remove_column :line_customers, :tel_num, :string

    add_column :line_customers, :encrypted_address, :string
    add_column :line_customers, :encrypted_address_iv, :string
    add_column :line_customers, :encrypted_tel_num, :string
    add_column :line_customers, :encrypted_tel_num_vi, :string
  end
end
