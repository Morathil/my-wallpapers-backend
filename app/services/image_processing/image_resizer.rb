require "vips"

module ImageProcessing
  class ImageResizer
    def initialize(image)
      @image = image
    end

    def resize_to(pixel:)
      scaling_factor = pixel.to_f / [ @image.width, @image.height ].max
      @image.resize(scaling_factor)
    end

    def resize_by(factor:)
      @image.resize(factor)
    end
  end
end
