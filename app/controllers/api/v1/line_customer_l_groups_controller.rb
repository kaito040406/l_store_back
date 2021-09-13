class Api::V1::LineCustomerLGroupsController < ApplicationController
  before_action :authenticate_api_v1_user!, except: :create
  before_action :active_check, except: :create
  def create
    begin
      # 紐づけるグループ情報を取得
      group = LGroup.find(params[:l_group_id]).select("user_id")

      # 紐付けを行うグループの作成者IDが現在ログインしているユーザーのIDと同じかを確認
      if group.user_id == current_api_v1_user.id
        # 同一であれば紐付け処理を行う

        # パラメータをもとにデータ作成
        result = insert(
          params[:l_group_id],
          params[:line_customer_id],
          params[:group_name])

        # jsonデータ作成
        json_data = {
          json: {
            "status" => 200,
            "msg" => "success",
            "groupName" => group.name,
          }
        }
      else
        # 同一でなければ無効な処理と判断
        # jsonデータ作成
        json_data = {
          json: {
            "status" => 403,
            "msg" => "error",
          }
        }
      end
    rescue => e
      json_data = {
        json: {
          "status" => 500,
          "msg" => "error",
          "error" => e,
        }
      }
    end

    render json_data
  end

  def destroy
    begin
      # 対象のデータを取得
      trg_date = LineCustomerLGroup.find(params[:id])

      # 対象のデータのグループ情報を取得
      group = LGroup.find(trg_date.id) 

      # ログインしているユーザーのIDと対象のグループ情報を作成したユーザーが同一化を確認
      if current_api_v1_user.id == group.user_id
        # 同一であれば、データを削除
        trg_date.destroy
        # jsonデータ作成
        json_data = {
          json: {
            "status" => 200,
            "msg" => "success",
          }
        }
      else
        # 同一でなければ、無効なリクエストと判断
        # jsonデータ作成
        json_data = {
          json: {
            "status" => 403,
            "msg" => "error",
          }
        }
      end
    rescue => e
      json_data = {
        json: {
          "status" => 500,
          "msg" => "error",
          "error" => e,
        }
      }
    end

    render json_data
  end

  def index
    begin
      # ログイン中のユーザーを取得
      user = current_api_v1_user

      # line_customerに紐づくgroup情報を取得
      now_groups = LineCustomer.where(user_id: user.id, id: 1).joins(:l_groups).select("l_groups.name,line_customer_l_groups.id")

      # ユーザーが登録しているグループ情報を取得
      groups = LGroup.where(user_id: user.id).select("id, name")

      # 空の配列を用意
      now_group_list =[]
      group_list = []

      # 配列にデータを追加する
      now_groups.each do |now_group|
        now_group_list.push(
          {
            "currentGroupsId" => now_group.id,
            "currentGroupsName" => now_group.name,
          }
        )
      end
      groups.each do |group|
        group_list.push(
          {
            "groupId" => group.id,
            "groupName" => group.name,
          }
        )
      end

      # jsonデータ作成
      json_data = {
        json: {
          "status" => 200,
          "msg" => "success",
          "nowGroupList" => now_group_list,
          "groups" => group_list
        }
      }
    rescue => e
      # jsonデータ作成
      json_data = {
        json: {
          "status" => 500,
          "msg" => "error",
          "error" => e
        }
      }
    end

    render json_data
  end

  private
  # データ登録用のメソッド
  def insert(l_group_id,line_customer_id,name)
    return  LineCustomerLGroup.create(l_group_id: l_group_id, line_customer_id: line_customer_id, name: name)
  end
end


