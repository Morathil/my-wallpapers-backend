class DevicesController < ApplicationController
  # before_action :set_device, only: %i[ show update destroy ]
  before_action :authenticate_user!

  # GET /devices
  def index    
    @devices = Device.all

    render json: current_user.devices
  end

  # GET /devices/1
  def show
    id = params[:id]
    render json: current_user.devices.find_by(id: id)
  end

  # POST /devices
  def create
    device = Device.new(device_params)
    device.user_id = current_user.id

    if device.save
      render json: device, status: :created, location: device
    else
      render json: device.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /devices/1
  def update
    if @device.update(device_params)
      render json: @device
    else
      render json: @device.errors, status: :unprocessable_entity
    end
  end

  # DELETE /devices/1
  def destroy
    @device.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_device
    #   @device = Device.find(params.expect(:id))
    # end

    # Only allow a list of trusted parameters through.
    def device_params
      params.expect(device: [ :name, :width, :height ])
    end
end
