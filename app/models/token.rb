class Token < ApplicationRecord
  validates :chanel_id, presence: true, length: { maximum: CHANEL_ID_LENGTH = 10}
  validates :chanel_secret, presence: true, length: { maximum: CHANEL_SECRET_LENGTH = 32}
  validates :messaging_token, presence: true, length: { maximum:  MESSAGING_TOKEN_LENGTH = 172}
  validates :login_token, presence: true, length: { maximum: LOGIN_TOKEN_LENGTH = 172}

  belongs_to :user
end
