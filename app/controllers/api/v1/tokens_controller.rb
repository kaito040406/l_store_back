class Api::V1::TokensController < ApplicationController

  before_action :authenticate_api_v1_user!
  # IDがあるかを確認する回数
  @@recount = 5

  def index
    render json: { message: "Hello World!"}
  end

  def create
    if Token.exists?(user_id: current_api_v1_user.id)
      # 更新の場合
      # result = update_sql(current_api_v1_user.id,params[:chanel_id],params[:chanel_secret],params[:message_token],params[:login_token])
      @trg = Token.find_by(user_id: current_api_v1_user.id)
      result = @trg.update(token_params)
      if result
        render json: { status: 'SUCCESS', data: current_api_v1_user }
        return
      else
        render json: { status: 'ERROR', data: current_api_v1_user }
        return
      end
    else
      # 新規作成の場合
      @token = Token.new(token_params)
      @token.user_id = current_api_v1_user.id
      @token.access_id = make_random_id()
      # binding.pry
      if @token.save
        render json: { status: 'SUCCESS', data: current_api_v1_user }
        return
      else
        render json: { status: 'ERROR', data: current_api_v1_user }
        return
      end
    end
  end

  def show

  end

  private
  def token_params
    params.require(:token).permit(:chanel_id, :chanel_secret, :messaging_token, :login_token)
  end

  def is_login()
    if user_signed_in? then
      return true
    else
      return false
    end
  end

  def redirect_method()

  end



  # アクセスID作成用の関数
  def make_random_id()
    id = ''.tap { |s| 11.times { s << rand(0..9).to_s } }
    i = 1
    while i <= @@recount
      if Token.exists?(access_id: id) then
      else
        # 存在しない時はループを抜ける
        break
      end
      i = i + 1
    end
    if i != @@recount then
      return id
    else
      return 0
    end
  end
end
