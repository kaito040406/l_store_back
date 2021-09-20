class AddColumnLGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :l_groups, :count, :integer ,default: 0, null: false
  end
end
