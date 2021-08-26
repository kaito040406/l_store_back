class ChangeDataAgeToLineCustomers < ActiveRecord::Migration[6.1]
  def change
    change_column :line_customers, :age, :integer
  end
end
