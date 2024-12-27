require "mini_magick"
require 'stringio'
require "vips"

class ImageGroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_device, only: %i[ index show update destroy ]
  before_action :set_image_groups, only: %i[ index show update destroy ]
  before_action :set_image_group, only: %i[ show update destroy ]

  # GET /image_groups
  def index
    # response = @image_groups.includes(original_image: { file_attachment: :blob })
    render json: @image_groups
  end

  # GET /image_groups/1
  def show
    render json: @image_group
  end

  # POST /image_groups
  def create
    imageProcessingService = ImageProcessing::ImageProcessor.new(params[:file].path)
    size = imageProcessingService.get_size
    image_width = size[:width]
    image_height = size[:height]

    image = Image.new(image_params.merge(width: image_width, height: image_height))
    image.file.attach(params[:file])
    image.save!

    image_group = ImageGroup.new(image_group_params.merge(original_id: image.id))

    if image_group.save
      # Generate cropped and thumbnail async
      ImageGenerateJob.perform_async image_group.id

      render json: image_group, status: :created, location: image_group
    else
      render json: image_group.errors, status: :unprocessable_entity
    end
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
    def set_device
      @device = current_user.devices.find_by(id: params.expect(:device_id))
    end
    
    def set_image_groups
      @image_groups = @device.image_groups
    end

    def set_image_group
      @image_group = @image_groups.find(params.expect(:id))
    end

    def image_params
      image_params = JSON.parse(params[:image]).slice("image_type", "file")
    end

    # Only allow a list of trusted parameters through.
    def image_group_params
      JSON.parse(params[:image_group]).slice("device_id")
    end
end
