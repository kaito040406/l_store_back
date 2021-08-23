class RemoveColumnFromineCustomers < ActiveRecord::Migration[6.1]
  def change
    remove_column :tokens, :chanel_id, :string
    remove_column :tokens, :chanel_secret, :string
    remove_column :tokens, :messaging_token, :string
    remove_column :tokens, :login_token, :string
  end
end
