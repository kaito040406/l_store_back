class StripeSubscriptionDeleted

  def set_parameter(object)
    # stripeのcustomer_idからユーザーを検索
    trg_user = User.where(credit_id: object[:customer])

    # サブスクリプションのステータス更新
    trg_user.update(subscription_status: object[:status])
  end
  
end