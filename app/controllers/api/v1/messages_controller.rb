class Api::V1::MessagesController < ApplicationController
  before_action :authenticate_api_v1_user!
  def initialize()

  end
  def index

  end

  def create
    # if current_api_v1_user
      require 'net/http'
      require 'uri'
      require 'json' 

      # ログインしていない場合の処理
      # if !is_login() then
      #   redirect_method()
      #   return
      # end

      # ユーザー情報をセット
      result = insert(current_api_v1_user.id,params[:title],params[:body],params[:image])


      @inserted = Message.find(result)



      @Token = Token.find_by(user_id: current_api_v1_user.id)

      token = @Token.messaging_token

      # post先のurl
      uri = URI.parse('https://api.line.me/v2/bot/message/broadcast')
      http = Net::HTTP.new(uri.host,uri.port)
      http.use_ssl = true

      # Header
      headers = {
          'Authorization'=>"Bearer #{token}",
          'Content-Type' =>'application/json',
          'Accept'=>'application/json'
      }
      send_message = params[:title]

      puts @inserted.image
      send_message = send_message + "\n" + params[:body]
      # Body
      params = {"messages" => [{"type" => "text", "text" => send_message}]}


      paramsImg = {"messages" => [{"type" => "image", "originalContentUrl" => @inserted.image.to_s, 'previewImageUrl' => @inserted.image.to_s}]}

      response = http.post(uri.path, paramsImg.to_json, headers)
      response = http.post(uri.path, params.to_json, headers)

      render json: { is_login: true, data: current_api_v1_user }

    # end
  end

  private
  # リダイレクト処理
  def is_login()
    if user_signed_in? then
      return true
    else
      return false
    end
  end

  def redirect_method()
    redirect_to '/users/sign_in'
  end

  def insert(user_id,title, body, image)
    result = Message.create(user_id: user_id, title: title, body: body, image: image)
    return result.id
  end
end
