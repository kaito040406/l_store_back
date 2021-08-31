class Api::V1::UsersController < ApplicationController
  # before_action :authenticate_api_v1_user!
  def show
    begin
      # ユーザーの公式アカウントに対するフォロー情報を取得
      follow_records = FollowRecord.where(user_id: 1).order(created_at: "ASC")

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
            "backgroundColor" => "#43a047",
            "borderColor" => "#43a047",
            "data" => follow_record_histories,
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
        "detail" => e
      }
    end
    render json: json_data
  end
end
