class Api::V1::LGroupsController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :active_check
  def index
    begin
      # グループ名の一覧を取得
      group_names = LGroup.where(user_id: current_api_v1_user.id).select("id,name,count")

      # 空の配列を用意
      group_name_list = []

      # 配列にデータを追加
      group_names.each do |group_name|
        group_name_list.push(
          {
            "groupId" => group_name.id,
            "groupName" => group_name.name,
            "groupCount" => group_name.count
          }
        )
      end

      # 返却用のデータ作成
      json_data = {
        json:  {
          "msg" => "succsess",
          "groupNameList" => group_name_list
        },
        status: 200
      }
    rescue => e

      # 処理が失敗した際の返却データ
      json_data = {
        json:  {
          "msg" => "error",
          "error" => e
        },
        status: 500
      }
    end

    render json_data
  end

  def create
    begin
      # データをインサート
      result = insert(current_api_v1_user.id, params[:group_name])

      # 返却用のデータ作成
      json_data = {
        json:  {
          "msg" => "succsess",
          "groupId" => result.id,
          "groupName" => result.name
        },
        status: 200
      }
    rescue => e

      # 処理が失敗した際の返却データ
      json_data = {
        json:  {
          "msg" => "error",
          "error" => e
        },
        status: 500
      }
    end
    render json_data
  end

  def update
    begin
      # 更新対象のグループ情報を取得
      trg_group = LGroup.find_by(id: params[:id], user_id: current_api_v1_user.id)

      # データを更新
      result = data_update(trg_group, params[:group_name])

      # 返却用のデータ作成
      json_data = {
        json:  {
          "msg" => "succsess",
          "groupId" => result.id,
          "groupName" => result.name
        },
        status: 200
      }
    rescue => e
      logger.error(e)
      # 処理が失敗した際の返却データ
      json_data = {
        json:  {
          "msg" => "error",
          "error" => e
        },
        status: 500
      }
    end

    render json_data
  end

  def destroy
    begin
      # 削除対象のグループ情報を取得
      trg_group = LGroup.find_by(id: params[:id], user_id: current_api_v1_user.id)

      # データ削除
      trg_group.destroy

      # 返却用のデータ作成
      json_data = {
        json:  {
          "msg" => "succsess",
        },
        status: 200
      }
    rescue => e

      # 処理が失敗した際の返却データ
      json_data = {
        json:  {
          "msg" => "error",
          "error" => e
        },
        status: 500
      }
    end
  end


  private
  def insert(user_id, group_name)
    return LGroup.create(user_id: user_id, name: group_name)
  end

  def data_update(group, name)
    return group.update(name: name)
  end
end