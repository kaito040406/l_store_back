class CreateImages < ActiveRecord::Migration[6.1]
  def change
    create_table :images do |t|
      t.references :user, index: true, foreign_key: true
      t.references :message, index: true, foreign_key: true
      t.string :image,     null: false
      t.timestamps
    end
  end
end
