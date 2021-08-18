class CreateLineCustomerLGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :line_customer_l_groups do |t|
      t.references :l_group, index: true, foreign_key: true
      t.references :line_customer, index: true, foreign_key: true
      t.timestamps
    end
  end
end
