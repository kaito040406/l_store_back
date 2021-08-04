class Message < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true
  belongs_to :user
  has_many :images, dependent: :destroy

  mount_uploader :image, ThumbnailUploader
end
