class CreatePushUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :push_users do |t|
      t.references :user, index: true, foreign_key: true
      t.string   :push_line_id,          null: false
      t.timestamps
    end
  end
end
