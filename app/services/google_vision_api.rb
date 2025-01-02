class GoogleVisionApi
  def self.get_crop_hints(image_buffer:, width:, height:, device_width:, device_height:)
    begin
      base64_encoded = Base64.strict_encode64(image_buffer)
      url = "https://vision.googleapis.com/v1/images:annotate?key=#{Rails.application.credentials.google_cloud_api_key!}"

      response = HTTParty.post(url, headers: { "Content-Type" => "application/json" }, body: JSON.generate({
        "requests": [ {
          "image": { "content": base64_encoded },
          "features": [
            { "type": "CROP_HINTS", "maxResults": 1 }
          ],
          "imageContext": {
            "cropHintsParams": {
              "aspectRatios": [ device_width.to_f / device_height ]
            }
          }
        } ]
      }))

      crop_hints = response.parsed_response.dig("responses", 0, "cropHintsAnnotation", "cropHints", 0, "boundingPoly", "vertices")

      x_values = crop_hints.map { |hint| hint["x"] }.compact.uniq
      y_values = crop_hints.map { |hint| hint["y"] }.compact.uniq

      x = (x_values.min + x_values.max) / 2
      y = (y_values.min + y_values.max) / 2

      { x: x, y: y }
    rescue Exception => e
      Rails.logger.debug "Rescue --- #{e}"
      { x: width / 2, y: height / 2 }
    end
  end
end
