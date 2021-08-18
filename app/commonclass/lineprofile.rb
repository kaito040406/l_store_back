# LINEのuserIDからプロフィール情報を取得するクラス
class Lineprofile < Apicommon

  # コンストラクタ 引数はLINEのuserId
  def initialize(original_id)
    url = "https://api.line.me/v2/bot/profile/#{original_id}"
    @uri = URI.parse(url)
    @http = Net::HTTP.new(@uri.host,@uri.port)
    @http.use_ssl = true

    # original_idをセット
    @original_id = original_id
  end

  # ラインのプロファイル情報を取得するメソッド
  def getProfile
    response = getResponse()
    case response
    when Net::HTTPSuccess then
      contact = JSON.parse(response.body)
      profile_data = {
        "response" => "success",
        "name" => contact['displayName'],
        "image" => contact['pictureUrl'],
        "original_id" => @original_id
      }
    else
      profile_data = {
        "response" => "error"
      }
    end
    return profile_data
  end

  # 以下privateメソッド
  private
    # LINEにprofile情報を取得するメソッド
    def getResponse
      response = @http.get(@uri.path, getHeader())
      return response
    end
end