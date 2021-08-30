module AgeCheck::AgeCheck extend self
  require "date"

  def batch
    begin
      # 出力するログを指定
      logger = Logger.new("log/" + ENV['ENV'] + ".log")

      logger.info("Start age chat")

      # 今日の日付を取得
      d = Date.today

      # 検索用フォーマット変更
      trg_day = d.strftime("%m-%d")

      # 計算用フォーマット
      cal_day = d.strftime("%Y%m%d")

      # 今日が誕生日のユーザーを取得
      birth_day_users = LineCustomer.where("birth_day like ?", "%"+trg_day)

      birth_day_users.each do |birth_day_user|
        # 計算用フォーマットに変更
        cal_birth_day_user = birth_day_user.birth_day.strftime("%Y%m%d")

        # 年齢の計算
        age = (cal_day.to_i - cal_birth_day_user.to_i)/10000

        # データを更新
        birth_day_user.update(age: age)
      end
    rescue =>e
      # 例外が発生した際
      logger.info("Error occurred")
      logger.error(e)
    end
    logger.info("End age chat")
  end
end