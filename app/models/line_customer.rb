class LineCustomer < ApplicationRecord
  attr_encrypted :address, key: 'This is a key that is 191 bits!!'
  attr_encrypted :tel_num, key: 'This is a key that is 191 bits!!'

  belongs_to :user
  has_many :chats, dependent: :destroy
  has_many :line_customer_memos, dependent: :destroy
  has_many :line_customer_l_groups, dependent: :destroy
end
