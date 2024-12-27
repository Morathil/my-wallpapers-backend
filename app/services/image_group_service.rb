class ImageGroupService
  def initialize(image_group_id)
    @image_group = ImageGroup.find(image_group_id)
    @original_image = @image_group.original_image
    @device = @image_group.device
  end

  def generate_cropped_and_thumbnail_by_crop_hints
    # crop_hints = GoogleVisionApi.get_crop_hints(@original_image.file)
    crop_hints = [{"x"=>2449}, {"x"=>4897}, {"x"=>4897, "y"=>3264}, {"x"=>2449, "y"=>3264}]

    imageProcessingService = ImageProcessing::ImageProcessor.new(@original_image.file.path)
    cropped_response = imageProcessingService.generate_cropped_and_thumnail(device_width: @device.width, device_height: @device.height, crop_hints: crop_hints) # TODO: wallpaper orientation

    cropped_blob = generated_cropped_and_thumbnail[:cropped_blob]
    cropped_width = generated_cropped_and_thumbnail[:cropped_width]
    cropped_height = generated_cropped_and_thumbnail[:cropped_height]

    create_cropped(cropped_image_blob: cropped_blob, width: cropped_width, height: cropped_height)

    thumbnail_blob = generated_cropped_and_thumbnail[:thumbnail_blob]
    thumbnail_width = generated_cropped_and_thumbnail[:thumbnail_width]
    thumbnail_height = generated_cropped_and_thumbnail[:thumbnail_height]

    create_thumbnail(thumbnail_image_blob: thumbnail_blob, width: thumbnail_width, height: thumbnail_height)
  end

  private

  def create_cropped(cropped_image_blob:, width:, height:)
    cropped_image = Image.new(width: width, height: height, image_type: Image.image_types[:cropped])
    cropped_image.file.attach(cropped_image_blob)
    cropped_image.save!
  end

  def create_thumbnail(thumbnail_image_blob:, width:, height:)
    thumbnail_image = Image.new(width: width, height: height, image_type: Image.image_types[:cropped])
    thumbnail_image.file.attach(thumbnail_image_blob)
    thumbnail_image.save!
  end

  # def create_cropped_and_thumbnail_images()
  #   ActiveRecord::Base.transaction do
  #     cropped_image = Image.new(width: @original_image.width, height: @original_image.height, image_type: Image.image_types[:cropped])
  #     cropped_image.file.attach(@original_image.file.blob)
  #     cropped_image.save!

  #     thumbnail_image = Image.new(width: @original_image.width, height: @original_image.height, image_type: Image.image_types[:thumbnail])
  #     thumbnail_image.file.attach(@original_image.file.blob)
  #     thumbnail_image.save!

  #     @image_group.update(thumbnail_id: thumbnail_image.id, cropped_id: cropped_image.id)
  #   end    
  # end
end