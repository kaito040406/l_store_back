class Api::V1::UsersController < ApplicationController
  # ここは後ほど修正
  before_action :authenticate_api_v1_user!, except: :create_subscription
  before_action :active_check, except: :create_subscription
  # 過去７日間のデータを取得
  def last_seven_day
    begin
      # ユーザーの公式アカウントに対するフォロー情報を取得
    # ここは後ほど修正
      follow_records = FollowRecord.where(user_id: current_api_v1_user.id).order(created_at: :desc).limit(7)

      # からの配列を用意
      follow_record_histories = []
      follow_sum_record_histories = []
      follow_record_days = []
      unfollow_record_histories = []


      # 取得したデータをもとに配列データを作成
      follow_records.each do |follow_record|
        # そうフォロワー数を取得
        follow_sum = follow_record.follow + follow_record.unfollow

        # 配列に追加
        follow_record_histories.push(follow_record.follow)

        follow_sum_record_histories.push(follow_sum)

        unfollow_record_histories.push(follow_record.unfollow)

        follow_record_days.push(follow_record.created_at.strftime("%m/%d"))
      end

      json_data = {
        # "message" => "success",
        "datasets" => [
          {
            "backgroundColor" => "#06c755",
            "borderColor" => "#06c755",
            "data" => follow_sum_record_histories,
            "label" => "フォロー数"
          },
          {
            "backgroundColor" => "#e53935",
            "borderColor" => "#e53935",
            "data" => unfollow_record_histories,
            "label" => "ブロック数"      
          }
        ],
        "labels" => follow_record_days
      }
    rescue => e
      json_data = {
        # "message" => "error",
        "datasets" => e
      }
    end
    render json: json_data
  end


  # 過去７週間のデータを取得(後でリファルタリング)
  def last_seven_week
    begin
      # 過去7週間分のデータ取得
      follow_records = FollowRecord.where(user_id: current_api_v1_user.id).order(created_at: :desc).limit(49)

      # 空の配列を用意
      follow_record_histories = []
      follow_sum_record_histories = []
      follow_record_days = []
      unfollow_record_histories = []

      # 制御用の変数
      i = 1

      # 取得したデータをもとに配列データを作成
      follow_records.each do |follow_record|
        if i == 1 or i % 7 == 0
          # 総フォロワー数を取得
          follow_sum = follow_record.follow + follow_record.unfollow

          # 配列に追加
          follow_record_histories.push(follow_record.follow)

          follow_sum_record_histories.push(follow_sum)

          unfollow_record_histories.push(follow_record.unfollow)

          follow_record_days.push(follow_record.created_at.strftime("%m/%d"))
        end
        i = i + 1
      end

      json_data = {
        # "message" => "success",
        "datasets" => [
          {
            "backgroundColor" => "#06c755",
            "borderColor" => "#06c755",
            "data" => follow_sum_record_histories,
            "label" => "フォロー数"
          },
          {
            "backgroundColor" => "#e53935",
            "borderColor" => "#e53935",
            "data" => unfollow_record_histories,
            "label" => "ブロック数"      
          }
        ],
        "labels" => follow_record_days
      }
    rescue => e
      json_data = {
        # "message" => "error",
        "datasets" => e
      }
    end
    # json返却
    render json: json_data
  end


  # 過去7ヶ月のデータを取得(後でリファルタリング)
  def last_seven_month
    begin
      # 過去7週間分のデータ取得
      # あいまい検索を用いて初月のデータを取得
      follow_records = FollowRecord.where(user_id: current_api_v1_user.id).where("created_at LIKE ?", "%-01 %").order(created_at: :desc).limit(7)

      # 空の配列を用意
      follow_record_histories = []
      follow_sum_record_histories = []
      follow_record_days = []
      unfollow_record_histories = []

      # 取得したデータをもとに配列データを作成
      follow_records.each do |follow_record|
        # 総フォロワー数を取得
        follow_sum = follow_record.follow + follow_record.unfollow

        # 配列に追加
        follow_record_histories.push(follow_record.follow)
        follow_sum_record_histories.push(follow_sum)
        unfollow_record_histories.push(follow_record.unfollow)
        follow_record_days.push(follow_record.created_at.strftime("%m/%d"))
      end

      json_data = {
        # "message" => "success",
        "datasets" => [
          {
            "backgroundColor" => "#06c755",
            "borderColor" => "#06c755",
            "data" => follow_sum_record_histories,
            "label" => "フォロー数"
          },
          {
            "backgroundColor" => "#e53935",
            "borderColor" => "#e53935",
            "data" => unfollow_record_histories,
            "label" => "ブロック数"      
          }
        ],
        "labels" => follow_record_days
      }
    rescue => e
      json_data = {
        # "message" => "error",
        "datasets" => e
      }
    end
    # json返却
    render json: json_data
  end


  def get_follow_data
    # 最新のユーザーを1件取得
    # ここは後ほど修正
    follow_records = FollowRecord.where(user_id: current_api_v1_user.id).order(created_at: :desc).limit(2)

    # 返却用の配列を用意
    follow_count = 0
    unfollow_count = 0
    pre_follow_count = 0
    pre_unfollow_count = 0

    # ループ制御用の変数
    i = 0

    follow_records.each do |follow_record|
      if i == 0
        follow_count = follow_record.follow
        unfollow_count = follow_record.unfollow
      else
        # これら二つはいらない
        pre_follow_count = follow_record.follow
        pre_unfollow_count = follow_record.unfollow
      end
      # iをインクリメント
      i = i + 1
    end

    # 増加量を計算
    gain_follow = follow_count - pre_follow_count
    gain_unfollow = unfollow_count - pre_unfollow_count

    valid_account = (follow_count.to_f / (follow_count.to_f + unfollow_count.to_f)) * 100


    json_data = {
      "follow_count" => follow_count + unfollow_count,
      "unfollow_count" => unfollow_count,
      "pre_follow_count" => pre_follow_count,
      "pre_unfollow_count" => pre_unfollow_count,
      "gain_follow" => gain_follow,
      "gain_unfollow" => gain_unfollow,
      "valid_account" => valid_account.ceil(1)
    }

    render json: json_data
  end


  # 後で別のところに移動
  def create_subscription
    # idからcredit_idを取得
    user = User.find(params[:id])

    # credit_idとplan_idを取得
    credit_id = user.credit_id

    # credit_idを使ってcustomerを取得
    customer = get_customer(credit_id)

    # Stripeのトークン
    token = params[:body][:stripeToken]

    # ユーザ情報(メールアドレスなど一意なもの)
    client = user.uid

    # 顧客の詳細情報
    detail = params[:body][:detail]

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
              "status" => 200,
              "msg" => "success",
            }
          }
        else
          # サブスクリプションの登録に失敗した際の処理
          # 返却データ
          json_data = {
            status: 400,
            json:  {
              "status" => 400,
              "msg" => "Failed to register the subscription",
            }
          }
        end
      else
        # 顧客情報の登録に失敗した際の処理
        json_data = {
          status: 400,
          json:  {
            "status" => 400,
            "msg" => "Failed to register customer information",
          }
        }
      end
    else
    # 既にカード情報が登録されている場合更新処理を行う
      update_customer(customer.id,client,token,detail)
      json_data = {
        json:  {
          "status" => 200,
          "msg" => "Succeeded in updating customer information",
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
      # 今月を取得
      now = Time.current

      now_day = now.strftime("%d")

      if now_day.to_i > 15
        # 来月を取得
        next_month = now.next_month.strftime("%Y-%m")

        # 請求日を算出
        # 決済を同日の0時に行う
        next_expiration_date = next_month + "-15 23:59:59"
      else
        # 今月を取得
        now_month = now.strftime("%Y-%m")

        # 請求日を算出
        # 決済を同日の0時に行う
        next_expiration_date = now_month + "-15 23:59:59"
        logger.debug(next_expiration_date) 
      end

      # Subsctiptionの作成
      subscription = Stripe::Subscription.create(
        :customer => id,
        :items => [
          {:price => plan}
        ],
        # 初回請求日時を指定
        :billing_cycle_anchor => Time.parse(next_expiration_date).to_i,
        :proration_behavior => "none"
      )

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
