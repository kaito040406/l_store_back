class Api::V1::MemosController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :active_check
  def index
    trg_user = LineCustomer.find(params[:line_customer_id])
    memos = LineCustomerMemo.where(line_customer_id: trg_user.id).order(id: "DESC")
    render json: memos
  end

  def create
    if params[:body].bytesize <= 6000
      memo = LineCustomerMemo.create(line_customer_id: params[:line_customer_id], body: params[:body])
      render json: memo
    else
      render json: memo, status: 422
    end
  end

  def update
    # 対象のデータ取得
    if params[:body].bytesize <= 6000
      trg_memo = LineCustomerMemo.find(params[:id])

      # 対象を更新
      memo = trg_memo.update(body: params[:body])

      render json: memo
    else
      render json: memo, status: 422
    end
  end

  def destroy
    # 対象のデータ取得
    trg_memo = LineCustomerMemo.find(params[:id])

    # 対象を削除
    memo = trg_memo.destroy

    render json: memo
  end
end