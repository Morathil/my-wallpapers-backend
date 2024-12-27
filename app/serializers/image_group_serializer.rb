class ImageGroupSerializer < ActiveModel::Serializer
  attributes :created_at, :updated_at

  has_one :original_image
  has_one :cropped_image
  has_one :thumbnail_image
end