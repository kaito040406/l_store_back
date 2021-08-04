class CreateChats < ActiveRecord::Migration[6.1]
  def change
    create_table :chats do |t|
      t.references :line, index: true, foreign_key: true
      t.string :body
      t.string :image
      t.string :send_flg,     null: false
      t.timestamps
    end
  end
end
