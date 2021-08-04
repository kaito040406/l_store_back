class Chatimage < ApplicationRecord
  belongs_to :chat
  has_many :chatimage, dependent: :destroy
  mount_uploader :image, ImageUploader
end
