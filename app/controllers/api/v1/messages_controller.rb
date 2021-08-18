class Api::V1::MessagesController < ApplicationController
  before_action :authenticate_api_v1_user!
  require './app/commonclass/linepush'
  def initialize()

  end

  def create
    begin
      # ユーザー情報をセット
      result = insert(current_api_v1_user.id,params[:title],params[:body],params[:image])

      line = Linepush.new('broadcast')

      if params[:image] 
        result2 = insert_img(current_api_v1_user.id,result,params[:image])
        line.setImage(result2.image)
      end

      
      line.setTitle(params[:title])
      line.setBody(params[:body])
      line.setThumbnail(result.image)
      line.setToken(Token.find_by(user_id: current_api_v1_user.id).messaging_token)

      # 送信処理
      begin
        line.doPushMsg
        line.doPushImg
        msg={'status' => 'success'}
      rescue => error
        msg={'status' => 'error'}
      end

      render json: { is_login: true, data: msg }
    rescue => e
      render json: { is_login: true, data: e }
    end

  end

  private
  def insert(user_id,title, body,image)
    result = Message.create(user_id: user_id, title: title, body: body, image: image)
    return result
  end

  def insert_img(user_id,message_id,image)
    result = Image.create(user_id: user_id, message_id: message_id, image: image)
    return result
  end
end
