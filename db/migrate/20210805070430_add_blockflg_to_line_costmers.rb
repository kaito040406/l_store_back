class AddBlockflgToLineCostmers < ActiveRecord::Migration[6.1]
  def change
    add_column :line_costmers, :blockflg, :string
  end
end
