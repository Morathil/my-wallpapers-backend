class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_image, only: %i[ show update destroy ]

  # GET /images
  def index
    @images = Image.all

    render json: @images
  end

  # GET /images/1
  def show
    # render json: @image
    # TODO: Replace as this is only for test purposes to show image directly in postman
    file_content = @image.file.download
    send_data file_content, filename: @image.file.filename.to_s, type: @image.file.content_type, disposition: "attachment"
  end

  # POST /images
  def create
    @image = Image.new(image_params)

    if @image.save
      render json: @image, status: :created, location: @image
    else
      render json: @image.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /images/1
  def update
    if @image.update(image_params)
      render json: @image
    else
      render json: @image.errors, status: :unprocessable_entity
    end
  end

  # DELETE /images/1
  def destroy
    @image.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def image_params
      params.expect(image: [ :type, :width, :height, :file ])
    end
end
