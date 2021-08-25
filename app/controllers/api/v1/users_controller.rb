class Api::V1::UsersController < ApplicationController
  before_action :authenticate_api_v1_user!
  def show
    begin
      # ユーザーの公式アカウントに対するフォロー情報を取得
      follow_record = CreateFollowRecord.where(user_id: current_api_v1_user.id).order(created_at: "ASC")

      # からの配列を用意
      follow_record_histories = []

      # 制御用の変数
      i = 0

      # 現在のフォロー数用の変数を用意
      now_follow = nil

      # 現在のブロック数用の変数を用意
      now_unfollow = nil

      # 現在の有効フォロー数用の変数を用意
      now_sum_follow = nil

      # 取得したデータをもとに配列データを作成
      follow_records.each do |follow_record|

        if i == 0
          # 最新の日付のもののみ取得
          now_follow = follow_record.follow
          now_unfollow = follow_record.unfollow
          now_sum_follow = now_follow + now_unfollow
        end

        # そうフォロワー数を取得
        follow_sum = follow_record.follow + follow_record.unfollow

        # データ作成
        data = {
          "follow" => follow_record.follow,
          "sum_follow" => follow_sum
        }

        # 作成したデータを配列に入れる
        follow_record_histories.push(data)

        i = i + 1
      end

      json_data = {
        "message" => "success",
        "now_follow" => now_follow,
        "now_unfollow" => now_unfollow,
        "now_sum_follow" => now_sum_follow,
        "follow_history" => follow_record_histories
      }
    rescue => e
      json_data = {
        "message" => "error",
        "detail" => e
      }
    end
    render json: json_data
  end
end
