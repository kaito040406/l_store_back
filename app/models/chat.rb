class Chat < ApplicationRecord
  belongs_to :line_costmer
  mount_uploader :image, ThumbnailUploader
end
