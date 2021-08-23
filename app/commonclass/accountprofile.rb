class Accountprofile < Apicommon
  def initialize(day)
    # dayのフォーマットはyyyyMMddのみを受付
    url = "https://api.line.me/v2/bot/insight/followers"
    @uri = URI.parse(url)
    @http = Net::HTTP.new(@uri.host,@uri.port)
    @http.use_ssl = true
    @trg_day = "?date=" + day.strftime('%Y%m%d').to_s
  end

  def get_account_profile()
    response = getResponse()
    case response
    when Net::HTTPSuccess then
      contact = JSON.parse(response.body)
      account_data = {
        "response" => "success",
        "followers" => contact['followers'],
        "blocks" => contact['blocks']
      }
    else
      account_data = {
        "response" => "error"
      }
    end

    return account_data
  end

  # 以下privateメソッド
  private
    # LINEにprofile情報を取得するメソッド
    def getResponse
      response = @http.get(@uri.path + @trg_day, getHeader())
      return response
    end
end