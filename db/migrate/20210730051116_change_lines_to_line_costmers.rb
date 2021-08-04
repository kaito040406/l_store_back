class ChangeLinesToLineCostmers < ActiveRecord::Migration[6.1]
  def change
    rename_table :lines, :line_costmers
  end
end
