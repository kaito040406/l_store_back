class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.references :user, index: true, foreign_key: true
      t.string   :title,          null: false
      t.string   :body,     null: false
      t.string   :image
      t.timestamps
    end
  end
end
