class LineCostmerMemosToLineCustomerMemo < ActiveRecord::Migration[6.1]
  def change
    rename_table :line_costmer_memos, :line_customer_memos
  end
end
