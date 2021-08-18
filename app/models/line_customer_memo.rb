class LineCustomerMemo < ApplicationRecord
  validates :body, presence: true

  belongs_to :line_customer
end
