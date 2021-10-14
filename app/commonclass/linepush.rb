# messaging APIを用いて
# pushメッセージを送信するクラス
class Linepush < Apicommon

  @@url = 'https://api.line.me/v2/bot/message/'

  # コンストラクタ 引数はurlの最後の文字列
  def initialize(lsat_word)
    @uri = URI.parse(@@url + lsat_word)
    @http = Net::HTTP.new(@uri.host,@uri.port)
    @http.use_ssl = true
  end

  # メッセージタイトルセッター
  def setTitle(title)
    @title = title
  end

  # メッセージボディのセッター
  def setBody(body)
    @body = body
  end

  # サムネイル用のセッター
  def setThumbnail(thumbnail)
    @thumbnail = thumbnail
  end

  # シークレットIDのセッター
  def setSecret(secret)
    @secret = secret
  end

  # プッシュメッセージ作成用メソッド
  def doPushMsg
    # メッセージ部分作成
    # send_message = @title + "\n" + @body
    # タイトル消去なので削除 2021-10-13
    send_message =  @body
    params = {"messages" => [{"type" => "text", "text" => send_message}]}
    doPush(params)
  end

  # 1対1もしくは1対多用のプッシュメッセージ作成用メソッド
  def doPushMsgTo(to)
    # メッセージ部分作成
    send_message = @body
    params = {"to" => to,"messages" => [{"type" => "text", "text" => send_message}]}
    doPush(params)
  end

  # 画像用のプッシュメッセージ作成用メソッド
  def doPushImg
    paramsImg = {"messages" => [{"type" => "image", "originalContentUrl" => @image.to_s, 'previewImageUrl' => @thumbnail.to_s}]}
    doPush(paramsImg)
  end

  # 1対1もしくは1対多用の画像用プッシュメッセージ作成用メソッド
  def doPushImgTo(to)
    paramsImg = {"to" => to,"messages" => [{"type" => "image", "originalContentUrl" => @image.to_s, 'previewImageUrl' => @thumbnail.to_s}]}
    doPush(paramsImg)
  end

  # LINEからの画像を保存する用のメソッド
  def lineImgSave(request)
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = @secret
      config.channel_token = @token
    }
    body = request.body.read
    event = @client.parse_events_from(body)[0]
    image_response = @client.get_message_content(event.message['id'])
    file = File.open("/tmp/#{SecureRandom.uuid}.jpg", "w+b")
    file.write(image_response.body)

    return file
  end

  # 以下privateメソッド
  private
    # プッシュメッセージ実行用のメソッド
    def doPush(jsonParam)
      response = @http.post(@uri.path, jsonParam.to_json, getHeader())
      # logger.debug(response)
    end

    # クライアントのセッター
    def setClient()
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = @secret
        config.channel_token = @token
      }
    end

end