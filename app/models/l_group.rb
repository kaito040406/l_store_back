class LGroup < ApplicationRecord
  belongs_to :user
  has_many :line_customer_l_groups, dependent: :destroy
  has_many :line_costmers ,through: :line_customer_l_groups
end
