class CreateLineCostmerMemos < ActiveRecord::Migration[6.1]
  def change
    create_table :line_costmer_memos do |t|
      t.references :line_costmer, index: true, foreign_key: true
      t.string :body,     null: false
      t.timestamps
    end
  end
end
