class AddColumnToUser < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :subscription_plan, foreign_key: true
    add_column :users, :active_status, :string ,default: "0"
    add_column :users, :subscription_status, :string
    add_column :users, :service_expiration_date, :datetime
  end
end
