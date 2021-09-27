class Api::V1::StripesController < ApplicationController
  before_action :authenticate_api_v1_user!

  # 後で別のところに移動
  def create_subscription
    begin
      # idからcredit_idを取得
      # user = User.find(params[:id])
      user = current_api_v1_user

      # credit_idとplan_idを取得
      credit_id = user.credit_id

      # credit_idを使ってcustomerを取得
      customer = get_customer(credit_id)

      # Stripeのトークン
      token = params[:stripeToken]

      # ユーザ情報(メールアドレスなど一意なもの)
      client = user.email

      # 顧客の詳細情報
      detail = params[:detail]

      # 契約するプラン
      plan = ENV['SUB_PLAN']
      
      # stripeに登録されていない場合
      if customer.nil?
        # credit_idがnilもしくは空白の場合の処理

        # 作成された顧客のIDを取得
        new_customer = create_customer(user,client,token,detail)

        if new_customer != nil 
          # 顧客情報の登録に成功した際の処理

          # サブスクリプション作成
          subscription = create_subscription_data(user,new_customer.id, plan)

          if subscription != nil
            # サブスクリプションの登録に成功した際の処理

            # 処理が成功した際の返却データ
            json_data = {
              json: {
                "msg" => "success",
              }
            }

            # ユーザーにお知らせのメールを送信
            StripeMailer.send_thank(user).deliver

          else
            # サブスクリプションの登録に失敗した際の処理
            # 返却データ
            json_data = {
              status: 400,
              json:  {
                "msg" => "Failed to register the subscription",
              }
            }
          end
        else
          # 顧客情報の登録に失敗した際の処理
          json_data = {
            status: 400,
            json:  {
              "msg" => "Failed to register customer information",
            }
          }
        end
      else
      # 既にカード情報が登録されている場合更新処理を行う
        update_customer(customer.id,client,token,detail)
        json_data = {
          json:  {
            "msg" => "Succeeded in updating customer information",
          }
        }
      end
    rescue => e
      logger.error(e)
      json_data = {
        status: 500,
        json:  {
          "msg" => "Server error",
        }
      }
    end
    render json_data
  end




  # 以下プライベートメソッド
  private
  # stripeに顧客情報を登録するメソッド
  def create_customer(user,client,token,detail)
    begin 
      # 顧客情報の作成
      customer = Stripe::Customer.create(
        :email => client,
        :source => token,
        :description => detail
      )

      # stripeに顧客情報を登録した後、customer.idをdbに保存
      user.update(credit_id: customer.id)

      return customer
    rescue => e
      logger.error(e)
      return nil
    end
  end

  # 顧客がサブスクリプションを登録する際に使用するメソッド
  def create_subscription_data(user,id, plan)
    begin 
      # 現在を取得
      now = Time.current

      # 現在の日だけ取得
      now_day = now.strftime("%d")

      # 決済日取得
      expiration_date = ENV["EXPIRATIONDATE"]

      # 数値データを作成
      expiration_date_int = expiration_date.to_i

      # 有効期限のテキストデータを作成
      # -dd hh:mm:ss
      settlement_date_text = "-" + ENV["EXPIRATIONDATE"] + " " + ENV["SETTLEMENTTIME"]

      # 決済日のテキストデータを作成
      # -dd hh:mm:ss
      expiration_date_text = "-" + ENV["EXPIRATIONDATE"] + " " + ENV["EXPIRATIONTIME"]

      if now_day.to_i > expiration_date_int
        # 来月を取得
        next_month = now.next_month.strftime("%Y-%m")

        # 請求日を算出
        # 決済を15日の0時に行う
        settlement_date = next_month + settlement_date_text

        # 有効期限を同日の23:59:59とする
        next_expiration_date = next_month + expiration_date_text
      else
        # 今月を取得
        now_month = now.strftime("%Y-%m")

        # 請求日を算出
        # 決済を15日の0時に行う
        settlement_date = now_month + settlement_date_text

        # 有効期限を同日の23:59:59とする
        next_expiration_date = now_month + expiration_date_text
      end

      # 15日以外の場合は決済日の指定処理
      if now_day.to_i != expiration_date_int
        # Subsctiptionの作成
        subscription = Stripe::Subscription.create(
          :customer => id,
          :items => [
            {:price => plan}
          ],
          # 初回請求日時を指定
          :billing_cycle_anchor => Time.parse(settlement_date).to_i,
          :proration_behavior => "none"
        )
      else
        # 15日以外の場合はデフォルト
        # Subsctiptionの作成
        subscription = Stripe::Subscription.create(
          :customer => id,
          :items => [
            {:price => plan}
          ]
        )     
      end

      # stripeにサブスクリプションを登録した後、planとサービス有効期限をdbに保存,またsubscription_statusを有効にし、active_statusを1に更新する
      user.update(plan_id: plan, service_expiration_date: next_expiration_date, subscription_status: "active" ,active_status: 1)

      return subscription
    rescue => e
      logger.error(e)
      return nil
    end
  end

  # stripeの顧客情報を更新するメソッド
  def update_customer(id,client,token,detail)
    customer = Stripe::Customer.update(
      id,
      {
        :email => client,
        :source => token,
        :description => detail
      }
    )
  end

  # stripeに登録されている顧客情報を取得するメソッド
  def get_customer(id)
    begin
      # customer取得
      customer = Stripe::Customer.retrieve(id)
      # customer返却
      return customer
    rescue => e
      # 存在しない場合、nilを返却
      return nil
    end
  end
end