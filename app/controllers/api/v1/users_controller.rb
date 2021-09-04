class Api::V1::UsersController < ApplicationController
  # ここは後ほど修正
  # before_action :authenticate_api_v1_user!
  # 過去７日間のデータを取得
  def last_seven_day
    begin
      # ユーザーの公式アカウントに対するフォロー情報を取得
    # ここは後ほど修正
      follow_records = FollowRecord.where(user_id: current_api_v1_user.id).order(created_at: "ASC").limit(7)

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
      follow_records = FollowRecord.where(user_id: 1).order(created_at: "ASC").limit(49)

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
    client = params[:body][:client]

    # 顧客の詳細情報
    detail = params[:body][:detail]

    # 契約するプラン
    plan = params[:body][:plan]
    
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
    # 既に登録されている場合更新処理を行う
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

  def create_subscription_data(user,id, plan)
    begin 
      # Subsctiptionの作成
      subscription = Stripe::Subscription.create(
        :customer => id,
        :items => [
          {:price => plan}
        ]
      )
      # stripeにサブスクリプションを登録した後、planをdbに保存
      user.update(plan_id: plan)
      return subscription
    rescue => e
      logger.error(e)
      return nil
    end
  end

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
