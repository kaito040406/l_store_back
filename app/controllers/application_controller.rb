class ApplicationController < ActionController::Base
        include DeviseTokenAuth::Concerns::SetUserByToken

        skip_before_action :verify_authenticity_token
        helper_method :current_api_v1_user, :user_signed_in?

        def active_check
                user = current_api_v1_user
                # 現在時刻取得
                now = Time.current
                # サービスの状態がactiveではないもしくは、有効期限が切れている場合、サービスの機能をストップ
                if user.subscription_status != "active" and user.subscription_status != "paid" or user.service_expiration_date < now
                        render json: { error: 'forbidden' }, status: :forbidden
                end
        end

end
