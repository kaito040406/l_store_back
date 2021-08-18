class Chatimage < ApplicationRecord
  belongs_to :chat
  
  mount_uploader :image, ImageUploader
end
