class Api::V1::ChatsController < LineCommonsController
  before_action :authenticate_api_v1_user!
  before_action :active_check
  def index
    chats = Chat.where(line_customer_id: params[:line_customer_id])
    render json: chats
  end

  def create
    begin
      trg_line_user = LineCustomer.find(params[:line_customer_id])

      message = params[:body]
      image = params[:image]

      # 画像もしくはメッセージがある時
      if message != nil or image != nil

        token = Token.find_by(user_id: current_api_v1_user.id)

        result = insert(trg_line_user.id, message, image)

        line = Linepush.new('multicast')

        line.setToken(token.messaging_token)

        line.setBody(message)

        # 配列を宣言
        to = []

        # 配列にIDを入れる
        to.push(trg_line_user.original_id)
        
        # 画像がある時の処理
        if image != nil
          img_result = insert_img(result.id, image)
          # logger.debug(img_result)
          line.setImage(img_result.image)
          line.setThumbnail(result.chat_image)
          # 画像送信
          line.doPushImgTo(to)
        end

        if message != nil
          # メッセージ送信
          line.doPushMsgTo(to)
        end

        msg = {
          body: result.body,
          chat_image: result.chat_image,
          created_at: result.created_at,
          id: result.id,
          image: trg_line_user.image,
          line_customer_id: result.line_customer_id,
          send_flg: result.send_flg,
          updated_at: result.updated_at
        }
      else
        msg = "error"
      end
      render json: { is_login: true, data: msg }
    rescue => e
      logger.debug(e)
      render json: { is_login: true, data: e }
    end    
  end

  private
  def insert(line_id, body, image)
    result = Chat.create(line_customer_id: line_id, body: body, chat_image: image, send_flg: "0")
    return result
  end

  def insert_img(chat_id,image)
    result = Chatimage.create(chat_id: chat_id, image: image)
    return result
  end
end
