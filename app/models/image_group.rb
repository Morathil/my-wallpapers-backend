class ImageGroup < ApplicationRecord
    belongs_to :device
    has_one :original_image, class_name: 'Image', foreign_key: 'id', primary_key: 'original_id'
    has_one :cropped_image, class_name: 'Image', foreign_key: 'id', primary_key: 'cropped_id'
    has_one :thumbnail_image, class_name: 'Image', foreign_key: 'id', primary_key: 'thumbnail_id'
end
