class Api::V1::LGroupsController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :active_check
  def create
    # groupの名前のパラメータ取得
    group_name = params[:name]

    # データをインサート
    insert(current_api_v1_user.id, group_name)
  end

  private
  def insert(user_id, group_name)
    LGroup.create(user_id, group_name)
  end
end