# 外部サービスよりAPI連携を行う際のクラス
class Apicommon
  require 'net/http'
  require 'uri'
  require 'json' 

  # コンストラクタ
  def initialize()

  end

  # トークンのセッター
  def setToken(token)
    @token = token
  end

  # 画像情報のセッター
  def setImage(image)
    @image = image
  end

  protected
  # リクエスト用のヘッダーのゲッター
  def getHeader
    headers = {
      'Authorization'=>"Bearer #{@token}",
      'Content-Type' =>'application/json',
      'Accept'=>'application/json'
    }
    return headers
  end
end