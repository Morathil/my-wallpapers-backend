require 'base64'

class ImageGenerateJob
  include Sidekiq::Job

  def perform(image_group_id)
    logger.debug '---------------- ImageGenerateJob'
    image_group_service = ImageGroupService.new(image_group_id)
    image_group_service.create_cropped_and_thumbnail_images_by_crop_hints
  end
end
