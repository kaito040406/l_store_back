# 支払い処理成功用のクラス
class StripePaid

  def set_parameter(object)

    # stripeのcustomer_idからユーザーを検索
    trg_user = User.where(credit_id: object[:customer])

    # 今月を取得
    now = Time.current 

    # 来月を取得
    next_month = now.next_month.strftime("%Y-%m")

    # 有効期限を算出
    # 決済を同日の0時に行う
    next_expiration_date = next_month + "-15 23:59:59"

    trg_user.update(subscription_status: object[:status], service_expiration_date: next_expiration_date)
  end

end