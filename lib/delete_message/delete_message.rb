module DeleteMessage::DeleteMessage extend self
  require "date"

  def batch
    begin
      # 出力するログを指定
      logger = Logger.new("log/" + ENV['ENV'] + ".log")

      logger.info("Start delete message")
      # 日付取得
      d = Date.today
      # タイムスタンプの場合は、00:00:00が基準
      # ターゲットの日付+1日で考える
      Message.where("created_at <= ?", d-89).find_each do |trg_datas|
        # 対象データを削除
        trg_datas.destroy
      end
    rescue => e
      # 例外が発生した際
      logger.info("Error occurred")
      logger.error(e)
    end
    logger.info("End delete message")
  end
end