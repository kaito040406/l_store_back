class AddAttrEncryptedToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :encrypted_credit_id, :string
    add_column :users, :encrypted_credit_id_iv, :string
    add_column :users, :plan_id, :string
  end
end
