class Chat < ApplicationRecord
  # validates :body, presence: true
  belongs_to :line_customer
  has_many :chatimage, dependent: :destroy
  mount_uploader :chat_image, ThumbnailUploader
end
