require "mini_magick"
require 'stringio'
require "vips"

class ImageGroupsController < ApplicationController
  before_action :set_image_group, only: %i[ show update destroy ]

  # GET /image_groups
  def index
    @image_groups = ImageGroup.all

    render json: @image_groups
  end

  # GET /image_groups/1
  def show
    render json: @image_group
  end

  # POST /image_groups
  def create
    # ActiveRecord::Base.transaction do
      logger.debug '-----------'

      imageProcessingService = ImageProcessing::ImageProcessor.new(params[:file].path)
      size = imageProcessingService.get_size
      image_width = size[:width]
      image_height = size[:height]

      image = Image.new(image_params.merge(width: image_width, height: image_height))
      image.file.attach(params[:file])
      image.save!

      device = Device.find(image_group_params['device_id'])

      # crop_hints = GoogleVisionApi.get_crop_hints(image.file)
      crop_hints = [{"x"=>2449}, {"x"=>4897}, {"x"=>4897, "y"=>3264}, {"x"=>2449, "y"=>3264}]
      Rails.logger.debug '-------------------------------------------------------'
      Rails.logger.debug crop_hints
      Rails.logger.debug device['width']

      # imageProcessingService.test( 1,  2,  3)
      generated_cropped_and_thumbnail = imageProcessingService.generate_cropped_and_thumnail(device_width: device['width'], device_height: device['height'], crop_hints: crop_hints) # TODO: wallpaper orientation

      cropped_blob = generated_cropped_and_thumbnail[:cropped_blob]
      cropped_width = generated_cropped_and_thumbnail[:cropped_width]
      cropped_height = generated_cropped_and_thumbnail[:cropped_height]

      cropped_image = Image.new(image_type: :cropped, width: cropped_width, height: cropped_height)
      cropped_image.file.attach(cropped_blob)
      cropped_image.save!

      thumbnail_blob = generated_cropped_and_thumbnail[:thumbnail_blob]
      thumbnail_width = generated_cropped_and_thumbnail[:thumbnail_width]
      thumbnail_height = generated_cropped_and_thumbnail[:thumbnail_height]

      thumbnail_image = Image.new(image_type: :thumbnail, width: thumbnail_width, height: thumbnail_height)
      thumbnail_image.file.attach(thumbnail_blob)
      thumbnail_image.save!

      #####


      # img = Vips::Image.new_from_file(params[:file].path)
      # image_width = img.width
      # image_height = img.height

      # image = Image.new(image_params.merge(width: image_width, height: image_height))
      # image.file.attach(params[:file])
      # image.save!
      
      # device = Device.find(image_group_params['device_id'])

      # logger.debug "--- #{image_width}, #{image_height}, #{device['width']}, #{device['height']}, 'portrait'"
      # new_dimensions = get_new_dimensions(image_width, image_height, device['width'], device['height'], :portrait)
      # logger.debug "new_dimensions #{new_dimensions["width"]} #{new_dimensions['height']}"
      # cropped_width = new_dimensions["width"]
      # cropped_height = new_dimensions['height']

      # # Scale Down To Cropped Size (not cropped yet)
      # if (image_height > cropped_height) # TODO: add wallpaperOrientation.isPortrait
      #   img = img.resize(cropped_height / image_height)
      # elsif (image_width > cropped_width)
      #   img = img.resize(cropped_width / image_width)
      # end

      # # img = Vips::Image.new_from_buffer(image.file.download, '')
      # img = img.crop(000, 000, 3000, 3000)  # Crop example
      # img = img.resize(1)  # Resize example
      # blob_data = img.write_to_buffer(".jpg")

      # # Create an ActiveStorage Blob from the processed image (as IO)
      # blob = ActiveStorage::Blob.create_and_upload!(
      #   io: StringIO.new(blob_data),  # Use StringIO for in-memory processing
      #   filename: "processed_#{Time.now.to_i}.jpg",
      #   content_type: 'image/jpeg'
      # )

      # cropped_blob = image.file.variant(resize_to_limit: [100, 100]).processed
      # cropped_image = Image.new(image_params.merge(image_type: :cropped))
      # # cropped_image.file.attach(cropped_blob.blob)
      # cropped_image.file.attach(blob)
      # cropped_image.save!

      # thumbnail_blob = image.file.variant(resize_to_limit: [10, 10]).processed
      # thumbnail_image = Image.new(image_params.merge(image_type: :cropped))
      # thumbnail_image.file.attach(thumbnail_blob.blob)
      # thumbnail_image.save!      

      image_group = ImageGroup.new(image_group_params.merge(original_id: image.id, cropped_id: cropped_image.id))
      # image_group = ImageGroup.new(image_group_params.merge(original_id: image.id, cropped_id: cropped_image.id, thumbnail_id: thumbnail_image.id))

      if image_group.save
        # ImageGenerateJob.perform_async image_group.id
        # render json: image_group, status: :created, location: image_group
        # file_content = cropped_image.file.download
        file_content = thumbnail_image.file.download
        logger.debug '-----------'
        # logger.debug file_content

        send_data file_content, filename: cropped_image.file.filename.to_s, type: cropped_image.file.content_type, disposition: 'attachment'
        # send_data img.write_to_buffer(".jpg"), filename: cropped_image.file.filename.to_s, type: cropped_image.file.content_type, disposition: 'attachment'
      else
        render json: image_group.errors, status: :unprocessable_entity
      end
    # end
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  # PATCH/PUT /image_groups/1
  def update
    if @image_group.update(image_group_params)
      render json: @image_group
    else
      render json: @image_group.errors, status: :unprocessable_entity
    end
  end

  # DELETE /image_groups/1
  def destroy
    @image_group.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image_group
      @image_group = ImageGroup.find(params.expect(:id))
    end

    def image_params
      image_params = JSON.parse(params[:image]).slice("image_type", "file")
      # image_params.permit(:type, :width, :height, :file)
    end

    # Only allow a list of trusted parameters through.
    def image_group_params
      JSON.parse(params[:image_group]).slice("device_id") # todo: think about
      # params.require(:image_group).permit(:device_id)
      # params.fetch(:image_group, {})
    end
end
