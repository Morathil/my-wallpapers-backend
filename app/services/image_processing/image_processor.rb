require "vips"

module ImageProcessing
  class ImageProcessor
    def initialize(filePath)
      @image = ::Vips::Image.new_from_file(filePath)
      @image_width = @image.width.to_f # convert to float for division
      @image_height = @image.height.to_f # convert to float for division
    end

    def get_size
      { width: @image_width, height: @image_height }
    end

    def generate_cropped_and_thumnail(device_width:, device_height:, target_wallpaper_orientation:)
      new_dimensions = ImageDimensions.new(vip_image: @image, device_width:, device_height:, new_wallpaper_orientation:)

      cropped_width = new_dimensions.target_width
      cropped_height = new_dimensions.target_height

      # Scale Down To Cropped Size (not cropped yet)
      device_size_scaling_factor = 1

      if @image_height > cropped_height && target_wallpaper_orientation == :portrait
        device_size_scaling_factor = cropped_height / @image_height
      elsif @image_width > cropped_width
        device_size_scaling_factor = cropped_width / @image_width
      end

      device_size_image_resizer = ImageProcessing::ImageResizer.new(@image)
      device_size_image = device_size_image_resizer.resize_by(factor: device_size_scaling_factor)

      device_size_image_buffer = device_size_image.write_to_buffer(".jpg")

      crop_hints = GoogleVisionApi.get_crop_hints(image_buffer: device_size_image_buffer, width: device_size_image.width, height: device_size_image.height, device_width:, device_height:)
      crop_center_x = crop_hints[:x]
      crop_center_y = crop_hints[:y]

      Rails.logger.debug "crop_hints"
      Rails.logger.debug crop_hints
      # Crop
      image_cropper = ImageProcessing::ImageCropper.new(image: device_size_image, cropped_height:, cropped_width:, crop_center_y:, crop_center_x:, target_wallpaper_orientation:)
      cropped_image = image_cropper.crop

      # Thumnail
      thumbnail_image_resizer = ImageProcessing::ImageResizer.new(cropped_image)
      thumbnail_image = thumbnail_image_resizer.resize_to(pixel: 320) # 0.3 scaling factor

      cropped_blob_data = cropped_image.write_to_buffer(".jpg")
      thumbnail_blob_data = thumbnail_image.write_to_buffer(".jpg")

      cropped_blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(cropped_blob_data),  # Use StringIO for in-memory processing
        filename: "cropped_#{Time.now.to_i}.jpg",
        content_type: "image/jpeg"
      )
      thumbnail_blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(thumbnail_blob_data),  # Use StringIO for in-memory processing
        filename: "thumbnail_#{Time.now.to_i}.jpg",
        content_type: "image/jpeg"
      )

      {
        cropped_blob: cropped_blob, cropped_width: cropped_image.width, cropped_height: cropped_image.height,
        thumbnail_blob: thumbnail_blob, thumbnail_width: thumbnail_image.width, thumbnail_height: thumbnail_image.height
      }
    end
  end
end
