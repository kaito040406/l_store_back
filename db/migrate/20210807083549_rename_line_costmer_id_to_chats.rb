class RenameLineCostmerIdToChats < ActiveRecord::Migration[6.1]
  def change
    rename_column :chats, :line_costmer_id, :line_customer_id
  end
end
