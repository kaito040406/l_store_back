class Api::V1::LineCustomersController < LineCommonsController

  require 'net/http'
  require 'uri'
  require 'json'

  before_action :authenticate_api_v1_user!, except: :create

  def index
    line_users = LineCustomer.where(user_id: current_api_v1_user.id, blockflg: "0").pluck(:id,:user_id,:name,:image)
    json_array = []
    line_users.each do |line_user|
      json_data = {
        "id" => line_user[0],
        "user_id" => line_user[1],
        "name" => line_user[2],
        "image" => line_user[3]
      }
      json_array.push(json_data)
    end
    render json: json_array
  end

  def show
    trg_user = LineCustomer.find(params[:id])

    begin
      # 年取得
      year = trg_user.birth_day.year

      # 月取得
      month = trg_user.birth_day.month

      # 日取得
      day = trg_user.birth_day.day
    rescue
      year =""
      month = ""
      day = ""
    end


    json_data = {
      "id" => trg_user.id,
      "user_id" => trg_user.user_id,
      "name" => trg_user.name,
      "image" => trg_user.image,
      "last_name" => trg_user.last_name,
      "first_name" => trg_user.first_name,
      "year" => year,
      "month" => month,
      "day" => day,
      "age" => trg_user.age,
      "sex" => trg_user.sex,
      "address" => trg_user.address,
      "tel_num" => trg_user.tel_num,
      "mail" => trg_user.mail
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

      line_customer.update(
        last_name: params[:last_name],
        first_name: params[:first_name],
        birth_day: birth_day, 
        age: params[:age], 
        sex: params[:sex], 
        address: params[:address], 
        tel_num: params[:tel_num], 
        mail: params[:mail])
      msg = "success"
    rescue => e
      msg = e
    end
    render json: msg
  end

  private

  # 受け取ったテキスト情報から日付に変換するメソッド
  def make_day(year,month,day)

    date = Date.pase(year + "/" + month + "/" + day)

    return date
  end
end