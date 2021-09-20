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
            "data" => follow_sum_record_histories.reverse,
            "label" => "フォロー数"
          },
          {
            "backgroundColor" => "#e53935",
            "borderColor" => "#e53935",
            "data" => unfollow_record_histories.reverse,
            "label" => "ブロック数"      
          }
        ],
        "labels" => follow_record_days.reverse
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
            "data" => follow_sum_record_histories.reverse,
            "label" => "フォロー数"
          },
          {
            "backgroundColor" => "#e53935",
            "borderColor" => "#e53935",
            "data" => unfollow_record_histories.reverse,
            "label" => "ブロック数"      
          }
        ],
        "labels" => follow_record_days.reverse
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
            "data" => follow_sum_record_histories.reverse,
            "label" => "フォロー数"
          },
          {
            "backgroundColor" => "#e53935",
            "borderColor" => "#e53935",
            "data" => unfollow_record_histories.reverse,
            "label" => "ブロック数"      
          }
        ],
        "labels" => follow_record_days.reverse
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
end
