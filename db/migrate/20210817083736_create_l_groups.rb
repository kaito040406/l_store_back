class CreateLGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :l_groups do |t|
      t.references :user, index: true, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end
  end
end
