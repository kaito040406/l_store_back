class AddToken < ActiveRecord::Migration[6.1]
  def change
    add_reference :tokens, :user, foreign_key: true
    add_column :tokens, :chanel_id, :string, limit: 10, null: false
    add_column :tokens, :chanel_secret, :string, limit: 32, null: false
    add_column :tokens, :messaging_token, :string, limit: 172, null: false
    add_column :tokens, :login_token, :string, limit: 172, null: false
    add_column :tokens, :access_id, :string, limit: 12, null: false
  end
end
