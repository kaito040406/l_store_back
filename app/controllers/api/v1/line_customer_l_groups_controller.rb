class Api::V1::LineCustomerLGroupsController < ApplicationController
  def create
    l_group_id = params[:l_group_id]
    line_customer_id = params[:line_customer_id]
    insert(l_group_id,line_customer_id)
  end

  private
  def insert(l_group_id,line_customer_id)
    LineCustomerLGroup.create(l_group_id: l_group_id, line_customer_id: line_customer_id)
  end
end