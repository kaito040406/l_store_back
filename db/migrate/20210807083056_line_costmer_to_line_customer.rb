class LineCostmerToLineCustomer < ActiveRecord::Migration[6.1]
  def change
    rename_table :line_costmers, :line_customers
  end
end
