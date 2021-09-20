class Api::V1::LineCustomersController < LineCommonsController

  require 'net/http'
  require 'uri'
  require 'json'
  require "date"
  before_action :authenticate_api_v1_user!, except: :create
  before_action :active_check, except: :create

  def index

    line_users = LineCustomer.where(
      user_id: current_api_v1_user.id,
      blockflg: "0"
    ).pluck(
      :id,
      :user_id,
      :name,
      :image,
      :last_name,
      :first_name,
      :mail)

    json_array = make_index_json(line_users)
    render json: json_array
  end

  def show
    # 対象のラインユーザーを取得
    trg_user = LineCustomer.find(params[:id])


    begin
      # 年取得
      year = trg_user.birth_day.year.to_i

      # 月取得
      month = trg_user.birth_day.month.to_i

      # 日取得
      day = trg_user.birth_day.day.to_i
    rescue
      year = nil
      month = nil
      day = nil
    end


    json_data = {
      "id" => trg_user.id,
      "user_id" => trg_user.user_id,
      "name" => trg_user.name,
      "image" => trg_user.image,
      "lastName" => trg_user.last_name,
      "firstName" => trg_user.first_name,
      "year" => year,
      "month" => month,
      "day" => day,
      "age" => trg_user.age.to_i,
      "sex" => trg_user.sex.to_i,
      "address" => trg_user.address,
      "tel" => trg_user.tel_num,
      "email" => trg_user.mail
    }
    render json: json_data
  end

  def create
    # ユーザーのトークン情報を取得
    token = Token.find_by(access_id: params[:token_access_id])

    if fromLine(request, token.chanel_secret)
      # インスタンス変数に,トークン情報をセット
      set_token(token)
      # フックの種類を取得
      event_type = params[:events][0][:type]
      if event_type == "follow"
        follow()
      elsif event_type == "unfollow"
        unfollow()
      elsif event_type == "message" or "image"
        resept_line_message(request,token)
      end
    end
  end

  def update
    begin
      # 対象のユーザーを指定
      line_customer = LineCustomer.find_by(id: params[:id], user_id: current_api_v1_user.id)

      # 受け取った年月日をdate型に変換
      birth_day = make_day(params[:year],params[:month],params[:day])
      age = make_age(birth_day)

      line_customer.update(
        last_name: params[:lastName],
        first_name: params[:firstName],
        birth_day: birth_day, 
        age: age, 
        sex: params[:sex], 
        address: params[:address], 
        tel_num: params[:tel], 
        mail: params[:email])
      msg = "success"
    rescue => e
      msg = e
    end
    render json: msg
  end

  # グループ検索用のアクション
  def tag_search_customer
    # ログイン中のユーザーを取得
    user = current_api_v1_user

    # パラメータを取得
    user_id = params[:user_id]

    # グループのIDを取得
    l_group_id = params[:l_group_id]

    # 現在ログインしているユーザーのIDとパラメータのIDが一致していることを確認
    if user.id == user_id.to_i
    # if "1" == user_id
      # 一致している場合
      line_users = 
      LineCustomer.where(
        user_id: user.id
      ).joins(
        :line_customer_l_groups
      ).merge(
        LineCustomerLGroup.where(
          l_group_id: l_group_id
          )
        ).pluck(
          :id,
          :user_id,
          :name,
          :image,
          :last_name,
          :first_name,
          :mail)
      json_array = make_index_json(line_users)
      render json: json_array
    else
      render json: "error", status: 403
    end
  end

  private

  # 受け取ったテキスト情報から日付に変換するメソッド
  def make_day(year,month,day)

    date = Date.parse(year.to_s + "/" + month.to_s + "/" + day.to_s)

    return date
  end

  # 年齢算出
  def make_age(birth_day)
      # 今日の日付を取得
      d = Date.today

      # 計算用フォーマット
      cal_day = d.strftime("%Y%m%d")

      # 誕生日を計算用に変換
      cal_birth_day = birth_day.strftime("%Y%m%d")

      # 年齢の計算
      age = (cal_day.to_i - cal_birth_day.to_i)/10000

      # 年齢を戻す
      return age
  end

  # 一覧表示用のjsonデータの作成
  def make_index_json(line_users)
    json_array = []
    line_users.each do |line_user|

      begin
        full_name = line_user[4] + line_user[5]
      rescue 
        full_name = ""
      end

      json_data = {
        "id" => line_user[0],
        "user_id" => line_user[1],
        "name" => line_user[2],
        "image" => line_user[3],
        "full_name" => full_name,
        "mail" => line_user[6]
      }
      json_array.push(json_data)
    end
    return json_array
  end
end