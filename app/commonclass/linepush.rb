class Linepush < Apicommon
  @@url = 'https://api.line.me/v2/bot/message/broadcast'

  def initialize()
    @uri = URI.parse(@@url)
    @http = Net::HTTP.new(@uri.host,@uri.port)
    @http.use_ssl = true
  end

  def setTitle(title)
    @title = title
  end

  def setBody(body)
    @body = body
  end

  def setThumbnail(thumbnail)
    @thumbnail = thumbnail
  end

  def setSecret(secret)
    @secret = secret
  end

  def doPushMsg
    # メッセージ部分作成
    send_message = @title + "\n" + @body
    params = {"messages" => [{"type" => "text", "text" => send_message}]}
    doPush(params)
  end

  def doPushMsgTo(to)
    # メッセージ部分作成
    send_message = @body
    params = {"to" => [to],"messages" => [{"type" => "text", "text" => send_message}]}
    doPush(params)
  end

  def doPushImg
    paramsImg = {"messages" => [{"type" => "image", "originalContentUrl" => @image.image.to_s, 'previewImageUrl' => @thumbnail.image.to_s}]}
    doPush(paramsImg)
  end

  def doPushImgTo(to)
    paramsImg = {"to" => [to],"messages" => [{"type" => "image", "originalContentUrl" => @image.image.to_s, 'previewImageUrl' => @thumbnail.image.to_s}]}
    doPush(paramsImg)
  end

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

  private
    def getHeader
      headers = {
        'Authorization'=>"Bearer #{@token}",
        'Content-Type' =>'application/json',
        'Accept'=>'application/json'
      }
      return headers
    end
  

    def doPush(jsonParam)
      response = @http.post(@uri.path, jsonParam.to_json, getHeader())
    end

    def setClient()
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = @secret
        config.channel_token = @token
      }
    end

end