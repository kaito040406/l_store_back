class Api::V1::MeMosController < ApplicationController
  before_action :authenticate_api_v1_user!
  def index
    trg_user = LineCustomer.find(params[:line_customer_id])
    memos = Memo.where(line_customer_id: trg_user.line_customer_id)
    render json: memos
  end

  def create
    memos = Memo.create(memo_params)
  end

  private
  def memo_params
    params.require(:memos).permit(:line_customer_id, :body)
  end

end