class LineCommonsController < ApplicationController
  require './app/commonclass/linepush'
  protected
  def resept_line_message(request)
    event_type = params[:events][0][:message][:type]
    original_id = params[:events][0][:source][:userId]
    if event_type == "text"
      # ここはモデルに書く
      trg_line_user = search_line_customer(original_id,params[:token_access_id])
      # インサートする
      insert(trg_line_user.id, params[:events][0][:message][:text],nil,"1")
      
    elsif event_type == "image"
      # ここはモデルに書く
      trg_line_user = search_line_customer(original_id,params[:token_access_id])

      line = Linepush.new
      token = Token.find_by(user_id: trg_line_user.user_id)
      line.setToken(token.messaging_token)
      line.setSecret(token.chanel_secret)
      img_file = line.lineImgSave(request)
      logger.debug(img_file)
      insert(trg_line_user.id, nil,img_file,"1")
    end
  end

  def insert(line_id,body,image,send_flg)
    Chat.create(line_costmer_id: line_id, body: body, image: image, send_flg: send_flg)
  end

  def search_line_customer(original_id,token_access_id)
    user_token = Token.find_by(access_id: token_access_id)
    trg_line_user = LineCostmer.find_by(original_id: original_id, user_id: user_token.user_id)
    return trg_line_user
  end

  def set_client(client_src, access_token)
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = access_token
      config.channel_token = client_src
    }
  end

  def fromLine(request, secret_id)
    http_request_body = request.raw_post
    hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, secret_id, http_request_body)
    signature = Base64.strict_encode64(hash)
    if request.env['HTTP_X_LINE_SIGNATURE'] == signature
      return true
    else
      return false
    end
  end

end