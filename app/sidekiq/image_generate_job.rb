require 'base64'

class ImageGenerateJob
  include Sidekiq::Job

  def perform(image_group_id)
    logger.debug '----------------'
    image_group_service = ImageGroupService.new(image_group_id)
    image_group_service.generate_cropped_and_thumbnail_by_crop_hints


    # image_group = ImageGroup.find(image_group_id)
    # image = image_group.original_image
    # crop_hints = GoogleVisionApi.get_crop_hints(image.file)
    # Example: Send image data to the external API
    # response = send_image_to_external_api(image.file)
    # response = ''

    # Process the API response and save to the database
    # process_api_response(image_group, image, response)
  end

  private

  # def send_image_to_external_api(file)
  #   base64_encoded = Base64.strict_encode64(file.read)
  #   url = "https://vision.googleapis.com/v1/images:annotate?key=#{Rails.application.credentials.google_cloud_api_key!}"

  #   response = HTTParty.post(url, headers: { 'Content-Type' => 'application/json' }, body: JSON.generate({
  #     "requests": [{
  #       "image": { "content": base64_encoded },
  #       "features": [
  #         { "type": "CROP_HINTS", "maxResults": 5 }
  #       ]
  #     }]
  #   }))

  #   response.parsed_response # Return the parsed JSON response
  # end

  # def process_api_response(image_group, image, response)
  #   ActiveRecord::Base.transaction do
  #     cropped_image = Image.new(width: image.width, height: image.height, image_type: Image.image_types[:cropped])
  #     cropped_image.file.attach(image.file.blob)
  #     cropped_image.save!

  #     thumbnail_image = Image.new(width: image.width, height: image.height, image_type: Image.image_types[:thumbnail])
  #     thumbnail_image.file.attach(image.file.blob)
  #     thumbnail_image.save!

  #     image_group.update(thumbnail_id: thumbnail_image.id, cropped_id: cropped_image.id)
  #   end
  # end
end
