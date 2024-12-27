class ImageGroupService
  def initialize(image_group_id)
    @image_group = ImageGroup.find(image_group_id)
    @original_image = @image_group.original_image
    @device = @image_group.device
  end

  def create_cropped_and_thumbnail_images_by_crop_hints
    crop_hints = GoogleVisionApi.get_crop_hints(@original_image.file)
    # TODO: handle multiple crop hints
    # crop_hints = [{"x"=>2449}, {"x"=>4897}, {"x"=>4897, "y"=>3264}, {"x"=>2449, "y"=>3264}]

    @original_image.file.open do |file|
      imageProcessingService = ImageProcessing::ImageProcessor.new(file.path)
      generated_cropped_and_thumbnail = imageProcessingService.generate_cropped_and_thumnail(device_width: @device.width, device_height: @device.height, crop_hints: crop_hints) # TODO: wallpaper orientation
  
      cropped_blob = generated_cropped_and_thumbnail[:cropped_blob]
      cropped_width = generated_cropped_and_thumbnail[:cropped_width]
      cropped_height = generated_cropped_and_thumbnail[:cropped_height]
  
      thumbnail_blob = generated_cropped_and_thumbnail[:thumbnail_blob]
      thumbnail_width = generated_cropped_and_thumbnail[:thumbnail_width]
      thumbnail_height = generated_cropped_and_thumbnail[:thumbnail_height]
      
      ActiveRecord::Base.transaction do
        cropped_image = create_image_by_type(image_blob: cropped_blob, width: cropped_width, height: cropped_height, image_type: Image.image_types[:cropped])
        thumbnail_image = create_image_by_type(image_blob: thumbnail_blob, width: thumbnail_width, height: thumbnail_height, image_type: Image.image_types[:thumbnail])

        @image_group.update(cropped_id: cropped_image.id, thumbnail_id: thumbnail_image.id)
      end
    end
  end

  private

  def create_image_by_type(image_blob:, width:, height:, image_type:)
    image = Image.new(width: width, height: height, image_type: image_type)
    image.file.attach(image_blob)
    image.save!
    image
  end
end