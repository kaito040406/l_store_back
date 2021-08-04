class Api::V1::ChatsController < LineCommonsController
  before_action :authenticate_api_v1_user!

  def index
    chats = Chat.where(line_costmer_id: params[:line_costmer_id])
    render json: { is_login: true, data: chats}
  end

  def create
    begin
      trg_line_user = LineCostmer.find(params[:line_costmer_id])
      # params[:messate]は仮
      # params[:image]は仮

      message = params[:message]

      result = insert(trg_line_user.id, message, params[:image], "0")

      token = Token.find_by(user_id: trg_line_user.id)

      line = Linepush.new

      line.setToken(token.messaging_token)

      line.setBody(message)

      if params[:image]
        insert_img(result.id, params[:image])
        line.setImage(params[:image])
        line.setThumbnail(params[:image])
        # 画像送信
        line.doPushImgTo(trg_line_user.original_id)
      end

      # メッセージ送信
      line.doPushMsgTo(trg_line_user.original_id)

      msg = "success"
      render json: { is_login: true, data: msg }
    rescue => e
      render json: { is_login: true, data: e }
    end    
  end

  private
  def insert(line_id, body, image)
    result = Chat.create(line_costmer_id: line_id, body: body, image: image, send_flg: "0")
    return result.id
  end

  def insert_img(user_id,image)
    result = Chatimage.create(chat_id: user_id, image: image)
    return result.id
  end
end
