require "vips"

module ImageProcessing
  class ImageCropper
    def initialize(image:, cropped_height:, cropped_width:, crop_center_y:, crop_center_x:, target_wallpaper_orientation:)
      @target_wallpaper_orientation = target_wallpaper_orientation
      @x = crop_center_x.to_i
      @y = crop_center_y.to_i
      @cropped_width = cropped_width
      @cropped_height = cropped_height
      @image = image
    end

    def crop
      if @target_wallpaper_orientation == :portrait
        crop_portrait
      else
        crop_landscape
      end
    end

    private

    def crop_portrait
      split_factor = 0.4
      push_direction_percent = 0.15

      is_on_left_third = @x < (@image.width * split_factor)
      is_on_right_third = @x > (@image.width - (@image.width * split_factor))

      factor = if is_on_left_third
                 1 + push_direction_percent
      elsif is_on_right_third
                 1 - push_direction_percent
      else
                 1
      end

      max_x = @image.width - @cropped_width
      min_x = 0

      new_x = [ [ max_x, [ min_x, (@x * factor - (@cropped_width / 2)).to_i ].max ].min, min_x ].max

      # image.crop(new_x, 0, @cropped_width, cropped_height)
      @image.crop(new_x, 0, @cropped_width, @image.height)
      # image.crop(@test_x0, 0, @test_x1 - @test_x0, @image.height)
    end

    def crop_landscape
      split_factor = 0.4
      push_direction_percent = 0.15

      is_on_top_third = @y < (image.height * split_factor)
      is_on_bottom_third = @y > (image.height - (image.height * split_factor))

      factor = if is_on_top_third
                 1 + push_direction_percent
      elsif is_on_bottom_third
                 1 - push_direction_percent
      else
                 1
      end

      max_y = @image.height - @cropped_height
      min_y = 0

      new_y = [ [ max_y, [ min_y, (@y * factor - (@cropped_height / 2)).to_i ].max ].min, min_y ].max

      # image.crop(0, new_y, cropped_width, cropped_height)
      @image.crop(0, new_y, @image.width, @cropped_height)
    end
  end
end
