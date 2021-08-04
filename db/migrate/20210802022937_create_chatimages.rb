class CreateChatimages < ActiveRecord::Migration[6.1]
  def change
    create_table :chatimages do |t|
      t.references :chat, index: true, foreign_key: true
      t.string :image,     null: false
      t.timestamps
    end
  end
end
