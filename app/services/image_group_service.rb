class ImageGroupService
  def initialize(image_group_id)
    @image_group = ImageGroup.find(image_group_id)
    @original_image = @image_group.original_image
    @device = @image_group.device
  end

  def create_cropped_and_thumbnail_images_by_crop_hints
    target_wallpaper_orientation = @image_group.device.portrait? ? :portrait : :landscape

    @original_image.file.open do |file|
      imageProcessor = ImageProcessing::ImageProcessor.new(file.path)
      generated_cropped = imageProcessor.generate_cropped(device_width: @device.width, device_height: @device.height, target_wallpaper_orientation:)
      generated_thumbnail = imageProcessor.generate_thumbnail

      ActiveRecord::Base.transaction do
        cropped_image = create_image_by_type(image_data: generated_cropped, image_type: Image.image_types[:cropped])
        thumbnail_image = create_image_by_type(image_data: generated_thumbnail, image_type: Image.image_types[:thumbnail])

        @image_group.update(cropped_id: cropped_image.id, thumbnail_id: thumbnail_image.id)
      end
    end
  end

  private

  def create_image_by_type(image_data:, image_type:)
    image = Image.new(width: image_data[:width], height: image_data[:height], image_type: image_type)
    image.file.attach(image_data[:blob])
    image.save!
    image
  end
end
