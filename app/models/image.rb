class Image < ApplicationRecord
  has_one_attached :file
  # belongs_to :image_group
  
  enum :image_type, original: "original", cropped: "cropped", thumbnail: "thumbnail"
end