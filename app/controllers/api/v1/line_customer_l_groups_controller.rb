class Api::V1::LineCustomerLGroupsController < ApplicationController
  def create
    l_group_id = params[:l_group_id]
    line_customer_id = params[:line_customer_id]
    name = params[:group_name]
    insert(l_group_id,line_customer_id,name)
  end

  def destroy
    trg_date = LineCustomerLGroup.find(params[:id])
    trg_date.destroy
  end

  def update
    trg_date = LineCustomerLGroup.find(params[:id])
    trg_date.update(name: params[:group_name])
    
  end

  private
  def insert(l_group_id,line_customer_id,name)
    LineCustomerLGroup.create(l_group_id: l_group_id, line_customer_id: line_customer_id, name: name)
  end
end