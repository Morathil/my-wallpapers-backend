require 'vips'

module ImageProcessing
  class ImageProcessor
    def initialize(filePath)
      @image = ::Vips::Image.new_from_file(filePath)
      @image_width = @image.width.to_f # convert to float for division
      @image_height = @image.height.to_f # convert to float for division
    end

    def get_size ()
      { width: @image_width, height: @image_height }
    end

    def generate_cropped_and_thumnail(device_width:, device_height:, crop_hints:)
      wallpaper_orientation = :portrait
      new_dimensions = get_new_dimensions(device_width, device_height, wallpaper_orientation)

      crop_center_x = (crop_hints[0]["x"] + crop_hints[1]["x"]) / 2
      crop_center_y = @image_height / 2
      cropped_width = new_dimensions[:width].to_f
      cropped_height = new_dimensions[:height].to_f

      # Scale Down To Cropped Size (not cropped yet)
      if (@image_height > cropped_height && wallpaper_orientation == :portrait)
        device_size_scaling_factor = cropped_height / @image_height
      elsif (@image_width > cropped_width)
        device_size_scaling_factor = cropped_width / @image_width
      end
      
      device_size_image_resizer = ImageProcessing::ImageResizer.new(@image) 
      device_size_image = device_size_image_resizer.resize_by(factor: device_size_scaling_factor)

      # Crop
      image_cropper = ImageProcessing::ImageCropper.new(image: device_size_image, cropped_height:, cropped_width:, crop_center_y:, crop_center_x:, wallpaper_orientation:)
      cropped_image = image_cropper.crop

      # Thumnail
      thumbnail_image_resizer = ImageProcessing::ImageResizer.new(cropped_image) 
      thumbnail_image = thumbnail_image_resizer.resize_to(pixel: 320) # 0.3 scaling factor

      cropped_blob_data = cropped_image.write_to_buffer(".jpg")
      thumbnail_blob_data = thumbnail_image.write_to_buffer(".jpg")

      cropped_blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(cropped_blob_data),  # Use StringIO for in-memory processing
        filename: "cropped_#{Time.now.to_i}.jpg",
        content_type: 'image/jpeg'
      )
      thumbnail_blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(thumbnail_blob_data),  # Use StringIO for in-memory processing
        filename: "thumbnail_#{Time.now.to_i}.jpg",
        content_type: 'image/jpeg'
      )

      return {
        cropped_blob: cropped_blob, cropped_width: cropped_image.width, cropped_height: cropped_image.height,
        thumbnail_blob: thumbnail_blob, thumbnail_width: thumbnail_image.width, thumbnail_height: thumbnail_image.height
      }
    end

    private

    def get_new_dimensions(device_width, device_height, wallpaper_orientation)
      device_width = device_width.to_f # convert to float for division
      device_height = device_height.to_f # convert to float for division
      image_aspect_ratio = @image_width / @image_height
      is_image_landscape = image_aspect_ratio > 1
      device_normalized_aspect_ratio = get_normalized_aspect_ratio(device_width, device_height)
      aspect_ratio_difference = (is_image_landscape ? (@image_width / @image_height) : (@image_height / @image_width) - device_normalized_aspect_ratio).abs
    
      new_width = 0.0
      new_height = 0.0
    
      if wallpaper_orientation == :landscape
        # Landscape orientation
        if is_image_landscape && aspect_ratio_difference < 0.1
          new_width = device_width
          new_height = device_width / image_aspect_ratio
        else
          new_width = [@image_width, device_width].min
          new_height = new_width / device_normalized_aspect_ratio
        end
      else
        # Portrait orientation
        if !is_image_landscape && aspect_ratio_difference < 0.1
          new_height = device_height
          new_width = device_height * image_aspect_ratio
        else
          new_height = [@image_height, device_height].min
          new_width = new_height / device_normalized_aspect_ratio
        end
      end
    
      { width: new_width, height: new_height }
    end

    def get_normalized_aspect_ratio (device_width, device_height)
      [device_width, device_height].max / [device_width, device_height].min
    end  
  end
end