class Message < ApplicationRecord
  belongs_to :user
  has_many :images, dependent: :destroy

  mount_uploader :image, ThumbnailUploader
end
