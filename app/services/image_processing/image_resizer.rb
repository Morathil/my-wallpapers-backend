require "vips"

module ImageProcessing
  class ImageResizer

    attr_reader :image, :image_width, :image_height

    def initialize(image)
      @image = image
      @image_width = image.width.to_f
      @image_height = image.height.to_f
    end

    def resize_to(pixel:)
      scaling_factor = pixel.to_f / [ image_width, image_height ].max
      @image.resize(scaling_factor)
    end

    def resize_to_target_dimensions(dimensions)
      target_dimensions_scaling_factor = 1
      target_width = dimensions.target_width
      target_height = dimensions.target_height

      if image_height > target_height && target_wallpaper_orientation == :portrait
        target_dimensions_scaling_factor = target_height / image_height
      elsif image_width > target_width
        target_dimensions_scaling_factor = target_width / image_width
      end

      resize_by(factor: target_dimensions_scaling_factor)
    end

    private def resize_by(factor:)
      @image.resize(factor)
    end
  end
end
