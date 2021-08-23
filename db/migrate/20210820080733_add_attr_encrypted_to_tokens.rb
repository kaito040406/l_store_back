class AddAttrEncryptedToTokens < ActiveRecord::Migration[6.1]
  def change
    add_column :tokens, :encrypted_chanel_id, :string
    add_column :tokens, :encrypted_chanel_id_iv, :string
    add_column :tokens, :encrypted_chanel_secret, :string
    add_column :tokens, :encrypted_chanel_secret_iv, :string
    add_column :tokens, :encrypted_messaging_token, :text
    add_column :tokens, :encrypted_messaging_token_iv, :string
    add_column :tokens, :encrypted_login_token, :text
    add_column :tokens, :encrypted_login_token_iv, :string
  end
end
