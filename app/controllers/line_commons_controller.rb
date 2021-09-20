class LineCommonsController < ApplicationController
  require './app/commonclass/linepush'
  require './app/commonclass/lineprofile'

  protected
  # LINEからメッセージを受信した際
  def resept_line_message(request,token)
    # イベントタイプとラインのIDを取得
    event_type = params[:events][0][:message][:type]
    original_id = params[:events][0][:source][:userId]
    # ユーザーが存在するかを確認
    if !LineCustomer.exists?(user_id: @token.user_id, original_id: original_id)
      logger.debug(@token.user_id)
      # 以下プロフィール情報を取得
      profile_hash = get_line_profile(original_id,@token.messaging_token)
      # 以上プロフィール情報を取得

      # プロフィールの取得レスポンスがsuccessの時
      if profile_hash["response"] == "success"
        insert_user(@token.user_id, original_id,profile_hash["name"],profile_hash["image"],"0")
      end
    end

    # メッセージタイプがtextの時
    if event_type == "text"

      # メッセージ内容
      text_message = params[:events][0][:message][:text]

      # 送られてきたメッセージがトークン情報と一致している時
      if text_message == @token.messaging_token
        # 既にpush_userにて登録されているかを確認
        if !PushUser.exists?(push_line_id: original_id)
          # push_line_idテーブルにデータを追加
          insert_push_user(@token.user_id, original_id)
        end

      # トークン以外の時
      else
        # 対象のline登録ユーザーを取得
        trg_line_user = search_line_customer(original_id)
        # インサートする
        insert(trg_line_user.id,text_message,nil,"1")

        do_receive_push(trg_line_user.name,trg_line_user.id)
      end


    # メッセージタイプがimageの時
    elsif event_type == "image"
      # 対象のline登録ユーザーを取得
      trg_line_user = search_line_customer(original_id)

      # 以下画像の処理
      line = Linepush.new(original_id)
      line.setToken(@token.messaging_token)
      line.setSecret(@token.chanel_secret)
      img_file = line.lineImgSave(request)
      # 以上画像の処理

      # インサートする
      insert(trg_line_user.id, nil,img_file,"1")
    end
  end

  # チャット情報のインサートメソッド
  def insert(line_id,body,image,send_flg)
    Chat.create(line_customer_id: line_id, body: body, chat_image: image, send_flg: send_flg)
  end

  # 登録ユーザー検索メソッド
  def search_line_customer(original_id)
    trg_line_user = LineCustomer.find_by(original_id: original_id, user_id: @token.user_id)
    return trg_line_user
  end


  # ラインからのアクセスチェックメソッド
  def fromLine(request, secret_id)
    http_request_body = request.raw_post
    hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, secret_id, http_request_body)
    signature = Base64.strict_encode64(hash)
    if request.env['HTTP_X_LINE_SIGNATURE'] == signature
      return true
    else
      return false
    end
  end

  # フォローアクションメソッド
  def follow()
    # lineのID取得
    original_id = params[:events][0][:source][:userId]

    # ユーザーがいるかを確認
    line_user = LineCustomer.find_by(user_id: @token.user_id, original_id: original_id)

    # ユーザーがいるかつブロックフラグが1の時
    if line_user != nil and line_user.blockflg == "1"

      # 名前と写真が変わった際の処理をここに記入予定
      line_user.update(blockflg: "0")

    # 上記以外(ユーザーがいないもしくはブロックフラグが0)
    else

      # line_customerテーブルに対象のユーザーの公式ラインユーザーがいるかを確認
      if !LineCustomer.exists?(user_id: @token.user_id)
        # push_line_idテーブルにデータを追加
        insert_push_user(@token.user_id, original_id)
      end

      # 以下プロフィール情報を取得
      profile_hash = get_line_profile(original_id,@token.messaging_token)

      # プロフィール取得レスポンスがsuccessの時
      if profile_hash["response"] == "success"
        insert_user(@token.user_id, original_id,profile_hash["name"],profile_hash["image"],"0")
      end
    end
  end

  # ブロックアクションメソッド
  def unfollow()

    # LINE IDを取得
    original_id = params[:events][0][:source][:userId]

    # トークンに紐づくユーザーを取得
    line_user = LineCustomer.find_by(user_id: @token.user_id, original_id: original_id)

    begin
      if line_user.blockflg == "0"
        line_user.update(blockflg: "1")

        # l_groupのcountの更新
        cange_count(line_user)
      end
    rescue => e
      logger.error(e)
    end
  end

  # ユーザー登録メソッド
  def insert_user(user_id, original_id,name,image,flg)
    LineCustomer.create(user_id: user_id, original_id: original_id, name: name, image: image, blockflg: flg)
  end

  # LINEのプロファイル取得用メソッド
  def get_line_profile(original_id, messaging_token)

    line_prifile = Lineprofile.new(original_id)

    line_prifile.setToken(messaging_token)

    return line_prifile.getProfile()
  end

  def set_token(token)
    @token = token
  end

  # メッセージ受信通知用のユーザー登録メソッド
  def insert_push_user(user_id,push_line_id)
    PushUser.create(user_id: user_id, push_line_id: push_line_id)
  end

  # メッセージ受信通知実行メソッド
  def do_receive_push(name,id)
    # 通知を受け取るユーザーを取得
    line_push_users = PushUser.where(user_id: @token.user_id)
    # 空の配列を準備
    to = []
    # 取得したユーザーのLINEIDをtoに格納
    line_push_users.each{ |line_push_user|
      to.push(line_push_user.push_line_id)
    }
    # 以下pushメッセージのインスタンス作成
    line = Linepush.new('multicast')
    line.setToken(@token.messaging_token)
    # make_receive_push_messageにてメッセージを作成
    line.setBody(make_receive_push_message(name,id))
    line.doPushMsgTo(to)
    # 以上pushメッセージのインスタンス作成

  end

  # メッセージ受信通知メソッド
  def make_receive_push_message(name,id)
    body = name + 
          "さんからメッセージを受信しました。" + 
          "\n" + 
          "http://" +
          ENV['FRONT_URL'] + 
          "/customers/" + 
          id.to_s
    return body
  end

  # アンフォロー時のl_group_count更新
  def cange_count(line_user)
    LineCustomerLGroup.where(line_customer_id: line_user.id).find_each do |trg_data|
      # 対象データを削除
      trg_data.destroy
    end
  end
end