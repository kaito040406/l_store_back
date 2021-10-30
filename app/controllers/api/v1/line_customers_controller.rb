class Api::V1::LineCustomersController < LineCommonsController

  require 'net/http'
  require 'uri'
  require 'json'
  require "date"
  before_action :authenticate_api_v1_user!, except: :create
  before_action :active_check, except: :create

  def index

    line_users = LineCustomer.where(user_id: current_api_v1_user.id,blockflg: "0")

    # 配列のデータを取得  
    line_user_list = make_user_list(line_users)

    render json: line_user_list
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

      # birth_dayがnilの時はageもnilにする
      if birth_day != nil
        age = make_age(birth_day)
      else
        age = nil
      end

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
      line_users = LineCustomer.where(user_id: user.id).joins(:line_customer_l_groups).merge(LineCustomerLGroup.where(l_group_id: l_group_id))

      # 配列のデータを取得  
      line_user_list = make_user_list(line_users)
      
      render json: line_user_list
    else
      render json: "error", status: 403
    end
  end

  private

  # 受け取ったテキスト情報から日付に変換するメソッド
  def make_day(year,month,day)

    # データがない時はnilを返す
    if year != nil && month != nil && day != nil
      date = Date.parse(year.to_s + "/" + month.to_s + "/" + day.to_s)
    else
      date = nil
    end
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
  def make_user_list(line_users)
    # からの配列を用意
    line_user_list = []

    line_users.each do |line_user|
      begin
        full_name = line_user.last_name + line_user.first_name 

        # 名前がnullの時の処理
        if full_name == nil 
          full_name = " "
        end

      rescue 
        full_name = " "
      end

      # メールアドレスがnullの時の処理
      if line_user.mail != nil
        mail = line_user.mail      
      else
        mail = " "
      end

      # 電話番号がnullの時の処理
      if line_user.tel_num != nil
        tel_num = line_user.tel_num      
      else
        tel_num = " "
      end

      line_user_hash ={
        "full_name" => full_name,
        "id" => line_user.id,
        "image" => line_user.image,
        "mail" => mail,
        "name" => line_user.name,
        "tel_num" => tel_num,
        "user_id" => line_user.user_id
      }
      line_user_list.push(line_user_hash)
    end

    return line_user_list
  end
end