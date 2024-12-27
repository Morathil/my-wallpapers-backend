class Image < ApplicationRecord
  has_one_attached :file
  
  enum :image_type, original: "original", cropped: "cropped", thumbnail: "thumbnail"
end