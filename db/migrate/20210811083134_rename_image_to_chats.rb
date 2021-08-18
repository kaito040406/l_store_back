class RenameImageToChats < ActiveRecord::Migration[6.1]
  def change
    rename_column :chats, :image, :chat_image
  end
end
