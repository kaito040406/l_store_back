class Api::V1::LineCustomerLGroupsController < ApplicationController
  before_action :authenticate_api_v1_user!, except: :create
  before_action :active_check, except: :create
  def create
    begin
      # 紐づけるグループ情報を取得
      group = LGroup.find(params[:l_group_id])

      # 各パラメータを変数に格納(group_idをsrtingsに変換 フロント側でかえてもらうかも)
      group_id = params[:l_group_id].to_s
      customer_id = params[:line_customer_id]

      # 紐付けを行うグループの作成者IDが現在ログインしているユーザーのIDと同じかを確認
      # もしくは、パラメータがnilでないかを確認
      if group.user_id == current_api_v1_user.id and isNum(group_id,customer_id) and isNonData(group_id,customer_id)
        # 同一であれば紐付け処理を行う

        # パラメータをもとにデータ作成
        result = insert(group_id, customer_id)

        # l_groupのcountを更新
        change_count(group)

        # jsonデータ作成
        json_data = {
          json: {
            "msg" => "success",
            "groupName" => group.name,
          },
          status: 200
        }
      else
        # 同一でなければ無効な処理と判断
        # jsonデータ作成
        json_data = {
          json: {
            "msg" => "error",
          },
          status: 403
        }
      end
    rescue => e
      logger.error(e)
      json_data = {
        json: {
          "msg" => "error",
          "error" => e,
        },
        status: 500
      }
    end

    render json_data
  end

  def destroy
    begin
      # 対象のデータを取得
      trg_date = LineCustomerLGroup.find(params[:id])

      # 対象のデータのグループ情報を取得
      group = LGroup.find(trg_date.l_group_id) 

      # ログインしているユーザーのIDと対象のグループ情報を作成したユーザーが同一化を確認
      if current_api_v1_user.id == group.user_id
        # 同一であれば、データを削除
        trg_date.destroy

        # l_groupのcountを更新
        change_count(group)

        # jsonデータ作成
        json_data = {
          json: {
            "msg" => "success",
          },
          status: 200
        }
      else
        # 同一でなければ、無効なリクエストと判断
        # jsonデータ作成
        json_data = {
          json: {
            "msg" => "error",
          },
          status: 403
        }
      end
    rescue => e
      logger.error(e)
      json_data = {
        json: {
          "msg" => "error",
          "error" => e,
        },
        status: 500
      }
    end

    render json_data
  end

  def index
    begin
      # ログイン中のユーザーを取得
      user = current_api_v1_user

      # line_customerに紐づくgroup情報を取得
      now_groups = LineCustomer.where(id: params[:line_customer_id]).joins(:l_groups).select("l_groups.name,line_customer_l_groups.id,line_customer_l_groups.l_group_id")

      # ユーザーが登録しているグループ情報を取得
      groups = LGroup.where(user_id: user.id).select("id, name")

      # 空の配列を用意
      now_group_list =[]
      group_list = []

      # 制御用の配列
      ctr_list = []

      # 配列にデータを追加する
      now_groups.each do |now_group|
        # idはLineCustomerLGroupのidを返却
        now_group_list.push(
          {
            "currentGroupsId" => now_group.id,
            "currentGroupsName" => now_group.name,
          }
        )
        # 制御用の配列にl_group_idを入れていく
        ctr_list.push(now_group.l_group_id)
      end

      groups.each do |group|

        if !ctr_list.include? group.id
          group_list.push(
            {
              "groupId" => group.id,
              "groupName" => group.name
            }
          )
        end
      end

      # jsonデータ作成
      json_data = {
        json: {
          "msg" => "success",
          "nowGroupList" => now_group_list,
          "groups" => group_list
        },
        status: 200
      }
    rescue => e
      logger.error(e)
      # jsonデータ作成
      json_data = {
        json: {
          "msg" => "error",
          "error" => e
        },
        status: 500
      }
    end

    render json_data
  end

  private
  # データ登録用のメソッド
  def insert(l_group_id,line_customer_id)
    begin
      result = LineCustomerLGroup.create(l_group_id: l_group_id, line_customer_id: line_customer_id)
    rescue => e
      logger.error(e)
    end
    return  result
  end

  # 受け取ったパラメータが、数字かどうかを確認するメソッド
  def isNum(group_id,customer_id)
    # 正規表現にて確認
    # group_id custom_id共に数字の時にtrueを返す
    if group_id =~ /^[0-9]+$/ and customer_id =~ /^[0-9]+$/ 
      return true
    else
      return false
    end
  end

  # 受け取ったデータ存在しないかを確認
  def isNonData(group_id,customer_id)
    # データがあるかどうかを確認
    result = !LineCustomerLGroup.exists?(l_group_id: group_id, line_customer_id: customer_id)

    if result
      return true
    else
      return false
    end
  end

  def change_count(group)
    count = LineCustomerLGroup.where(l_group_id: group.id).count
    group.update(count: count)
  end
end


