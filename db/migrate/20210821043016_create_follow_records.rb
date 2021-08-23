class CreateFollowRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :follow_records do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :follow, null: false
      t.integer :unfollow, null: false
      t.timestamps
    end
  end
end
