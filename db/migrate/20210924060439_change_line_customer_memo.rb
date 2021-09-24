class ChangeLineCustomerMemo < ActiveRecord::Migration[6.1]
  def change
    change_column :line_customer_memos, :body, :text, :limit=>6000
  end
end
