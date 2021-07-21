class Api::V1::TokensController < ApplicationController

  before_action :authenticate_user!
  # IDがあるかを確認する回数
  @@recount = 5

  def index
    
  end

  def new
    @token = Token.new
  end

  def create
    @token = Token.new(token_params)
    @token.user_id = current_user.id
    @token.access_id = make_random_id()

    if Token.exists?(user_id: current_user.id)
      update()
    else
      if @token.save
        redirect_to links_path
      else
        render :new
      end
    end
  end

  def update
    # アップデートする結果をbool型で受け取る
    result = update_sql(getMsgToken(), getLoginToken(), getChanelID(), getChanelSecret())
    if result then

    else
      redirect_to '/'
    end
  end


  private
  def token_params
    params.require(:token).permit(:chanel_id, :chanel_secret, :messaging_token, :login_token)
  end

  def is_login()
    if user_signed_in? then
      return true
    else
      return false
    end
  end

  def redirect_method()
    redirect_to '/users/sign_in'
  end

# insert用の関数
  def insert(user_id, message_token, login_token, chanel_id, chanel_secret, access_id)
    # トークン情報を作成
    result = Token.create(user_id: user_id, chanel_id: chanel_id, chanel_secret: chanel_secret, messaging_token: message_token, login_token: login_token ,access_id: access_id)
    
    return result
  end

  # update用の関数
  def update_sql(message_token, login_token, chanel_id, chanel_secret)
    # トークン情報を作成
    result = Token.update(chanel_id: chanel_id, chanel_secret: chanel_secret, messaging_token: message_token, login_token: login_token)
    
    return result
  end

  # アクセスID作成用の関数
  def make_random_id()
    id = ''.tap { |s| 11.times { s << rand(0..10).to_s } }
    i = 1
    while i <= @@recount
      if Token.exists?(access_id: id) then
      else
        # 存在しない時はループを抜ける
        break
      end
      i = i + 1
    end
    if i != @@recount then
      return id
    else
      return 0
    end
  end

  def getMsgToken
    @message_token
  end

  def setMsgToken(message_token)
    @message_token = message_token
  end

  def getLoginToken
    @login_token
  end

  def setLoginToken(login_token)
    @login_token = login_token
  end

  def getChanelID
    @chanel_id
  end

  def setChanelID(chanel_id)
    @chanel_id = chanel_id
  end

  def getChanelSecret
    @chanel_secret
  end

  def setChanelSecret(chanel_secret)
    @chanel_secret = chanel_secret
  end

  def getAccessId
    @access_id
  end

  def setAccessId(access_id)
    @access_id = access_id
  end

  def getUser
    @user
  end

  # ユーザーセット
  def setUser(id)
    @user = User.find(id)
  end

end
