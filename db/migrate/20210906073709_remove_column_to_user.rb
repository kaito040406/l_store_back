class RemoveColumnToUser < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :encrypted_credit_id, :string
    remove_column :users, :encrypted_credit_id_iv, :string
    add_column :users, :credit_id, :string
  end
end
