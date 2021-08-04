class RenameLineIdColumnToChats < ActiveRecord::Migration[6.1]
  def change
    rename_column :chats, :line_id, :line_costmer_id
  end
end
