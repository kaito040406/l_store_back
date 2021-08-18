class LineCustomer < ApplicationRecord
  belongs_to :user
  has_many :chats, dependent: :destroy
  has_many :line_customer_memos, dependent: :destroy
  has_many :line_customer_l_groups, dependent: :destroy
end
