class ImageSerializer < ActiveModel::Serializer
  attributes :image_type, :width, :height, :file_url

  def file_url
    Rails.application.routes.url_helpers.rails_blob_url(object.file, only_path: true) if object.file.attached?
  end
end