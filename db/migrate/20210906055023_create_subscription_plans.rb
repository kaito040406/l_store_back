class CreateSubscriptionPlans < ActiveRecord::Migration[6.1]
  def change
    create_table :subscription_plans do |t|
      t.string   :plan,           null: false
      t.integer  :price,          nill: false 
      t.string   :stripe_plan_id, nill: false
      t.timestamps
    end
  end
end
