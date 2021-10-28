class StripeMailer < ActionMailer::Base
  def send_payd(user, infomation)
    @user = user
    @infomation = infomation

    mail( 
      :from => '"L-STORE" <info@l-store.jp>',
      :to => @user.email,
      :subject => 'ご注文ありがとうございます(自動課金)'
    )
  end

  def send_thank(user)
    # ユーザー取得
    @user = user

    # 現在を取得
    now = Time.current

    # 現在の日だけ取得
    now_day = now.strftime("%d")

    # 決済日取得
    expiration_date = ENV["EXPIRATIONDATE"]

    # 数値データを作成
    expiration_date_int = expiration_date.to_i


    if now_day.to_i > expiration_date_int
        # 来月を取得
        next_month = now.next_month.strftime("%Y年%m月")

        settlement_date = next_month + ENV["EXPIRATIONDATE"] + "日"
    else
        # 今月を取得
        now_month = now.strftime("%Y年%m月")

        settlement_date = now_month + ENV["EXPIRATIONDATE"] + "日"
    end

    @settlement_date = settlement_date

    mail( 
      :from => '"L-STORE" <info@l-store.jp>',
      :to => @user.email,
      :subject => 'L-STOREお申し込み有難うございます'
    )
  end
end