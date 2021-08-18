class AddWebHookUrlToTokens < ActiveRecord::Migration[6.1]
  def change
    add_column :tokens, :web_hook_url, :string
  end
end
