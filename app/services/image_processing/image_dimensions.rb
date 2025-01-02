module ImageProcessing
  class ImageDimensions

    attr_reader :image_width, :image_height,
                :device_width, :device_height,
                :target_width, :target_height

    def initialize(vip_image:, device:, target_wallpaper_orientation:)
      @vip_image = vip_image
      @image_width = @vip_image.width.to_f # convert to float for division
      @image_height = @vip_image.height.to_f # convert to float for division
      @device_width = device.width.to_f # convert to float for division
      @device_height = device.height.to_f # convert to float for division

      target_wallpaper_orientation == :landscape ? calculate_target_landscape : calculate_target_portrait
    end

    def target_width
      target_width.to_f
    end

    def target_height
      target_height.to_f
    end

    private def calculate_target_landscape
      if image_landscape? && aspect_ratio_difference < 0.1
        target_width = device_width
        target_height = device_width / image_aspect_ratio
      else
        target_width = [ image_width, device_width ].min
        target_height = target_width / device_normalized_aspect_ratio
      end
    end

    private def calculate_target_portrait
      if !image_landscape? && aspect_ratio_difference < 0.1
        target_height = device_height
        target_width = device_height * image_aspect_ratio
      else
        target_height = [ image_height, device_height ].min
        target_width = target_height / device_normalized_aspect_ratio
      end
    end

    private def image_landscape?
      image_aspect_ratio > 1
    end

    private def image_aspect_ratio
      image_width / image_height
    end

    private def device_normalized_aspect_ratio
      [device_width, device_height].max / [device_width, device_height].min
    end

    private def aspect_ratio_difference
      (image_landscape ? image_aspect_ratio : (image_height / image_width) - device_normalized_aspect_ratio).abs
    end
  end
end