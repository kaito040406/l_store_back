class ChangeDataBodyToChats < ActiveRecord::Migration[6.1]
  def change
    change_column :chats, :body, :text
  end
end
