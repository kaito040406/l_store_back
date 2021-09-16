class LineCustomerLGroup < ApplicationRecord
  belongs_to :l_group, optional: true
  belongs_to :line_costmer, optional: true
end
