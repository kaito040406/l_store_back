class AddColumnLineCustomers < ActiveRecord::Migration[6.1]
  def change
    add_column :line_customers, :name_full, :string
    add_column :line_customers, :birth_day, :string
    add_column :line_customers, :age, :string
    add_column :line_customers, :sex, :integer
    add_column :line_customers, :address, :string
    add_column :line_customers, :tel_num, :string
    add_column :line_customers, :mail, :string
  end
end
