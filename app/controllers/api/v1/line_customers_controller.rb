class Api::V1::LineCustomersController < LineCommonsController

  require 'net/http'
  require 'uri'
  require 'json'

  # before_action :authenticate_api_v1_user!, except: :create

  def index
    line_users = LineCustomer.where(user_id: current_api_v1_user.id, blockflg: "0").pluck(:id,:user_id,:name,:image,:last_name,:first_name,:mail)
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
    render json: json_array
  end

  def show
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

      line_customer.update(
        last_name: params[:lastName],
        first_name: params[:firstName],
        birth_day: birth_day, 
        age: params[:age], 
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

  private

  # 受け取ったテキスト情報から日付に変換するメソッド
  def make_day(year,month,day)

    date = Date.parse(year.to_s + "/" + month.to_s + "/" + day.to_s)

    return date
  end
end