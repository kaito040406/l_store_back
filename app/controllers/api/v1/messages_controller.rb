class Api::V1::MessagesController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :active_check
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
        if params[:image] 
          line.doPushImg
        end
        msg={'status' => 'success'}
      rescue => error
        msg={'status' => 'error'}
      end

      render json: { is_login: true, data: msg }
    rescue => e
      render json: { is_login: true, data: e }
    end

  end

  def target_message
    begin
      # ターゲッティングするグループ
      l_group_id = params[:group_id]

      # id = params[:id]
      # ログインしているユーザーを取得
      user = current_api_v1_user
      # user = User.find(id)

      # グループIDが0以外
      if l_group_id != "0"

        # ユーザー情報をセット
        result = insert(user.id,params[:title],params[:body],params[:image])
        
        line_users = 
        LineCustomer.where(
          user_id: user.id
        ).joins(
          :line_customer_l_groups
        ).merge(
          LineCustomerLGroup.where(
            l_group_id: l_group_id
            )
          ).pluck(:original_id)

        # からの配列を用意
        line_user_list = []

        line_users.each do |line_user|
          line_user_list.push(line_user)
        end

        line = Linepush.new('multicast')

        # 画像がある時だけ以下の処理
        if params[:image] 
          result2 = insert_img(user.id,result,params[:image])
          line.setImage(result2.image)
        end

        line.setTitle(params[:title])
        line.setBody(params[:body])
        line.setThumbnail(result.image)
        line.setToken(Token.find_by(user_id: user.id).messaging_token)

        line.doPushMsgTo(line_user_list)

        # 画像があるときの処理
        if params[:image] 
          line.doPushImgTo(line_user_list)
        end
      
      else
        # グループIDが0 全員送信
        # ユーザー情報をセット
        result = insert(user.id,params[:title],params[:body],params[:image])

        line = Linepush.new('broadcast')

        if params[:image] 
          result2 = insert_img(user.id,result,params[:image])
          line.setImage(result2.image)
        end

        
        line.setTitle(params[:title])
        line.setBody(params[:body])
        line.setThumbnail(result.image)
        line.setToken(Token.find_by(user_id: user.id).messaging_token)

        # 送信処理
        line.doPushMsg
        if params[:image] 
          line.doPushImg
        end

      end

      json_data = {
        json: {
          "msg" => "success"
        },
        status: 200
      }

    rescue => e
      json_data = {
        json: {
          "msg" => "error",
          "error" => e
        },
        status: 500
      }
    end

    render json_data
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
