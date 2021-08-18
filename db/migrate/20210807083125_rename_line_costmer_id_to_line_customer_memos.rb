class RenameLineCostmerIdToLineCustomerMemos < ActiveRecord::Migration[6.1]
  def change
    rename_column :line_customer_memos, :line_costmer_id, :line_customer_id
  end
end
