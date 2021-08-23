module AccountCheck::AccountCheck extend self
  require "date"
  require './app/commonclass/accountprofile'

  def batch
    begin
      # 出力するログを指定
      logger = Logger.new("log/" + ENV['ENV'] + ".log")

      logger.info("Start account chat")

      # 登録してあるトークンデータを取得
      tokens = Token.all

      # 日付取得
      d = Date.today

      # ターゲットの日付
      # 2日前の情報しか拾えない
      trg_d = d-2

      # アカウント取得用インスタンス作成
      line_account = Accountprofile.new(trg_d)

      # 配列宣言
      insert_data = []

      tokens.each do |token|
        line_account.setToken(token.messaging_token)
        response_data = line_account.get_account_profile()
        if response_data["response"] == "success"
          hash_data = {
            user_id: token.user_id,
            follow: response_data["followers"],
            unfollow: response_data["blocks"],
            created_at: trg_d,
            updated_at: trg_d
          }
          insert_data.push(hash_data)
        end
      end
      # 一括登録を行う
      FollowRecord.insert_all(insert_data)      
    rescue =>e
      # 例外が発生した際
      logger.info("Error occurred")
      logger.error(e)
    end
    logger.info("End account chat")
  end
end