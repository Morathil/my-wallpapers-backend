class GoogleVisionApi
  def self.get_crop_hints(file)
    base64_encoded = Base64.strict_encode64(file.download)
    url = "https://vision.googleapis.com/v1/images:annotate?key=#{Rails.application.credentials.google_cloud_api_key!}"

    response = HTTParty.post(url, headers: { 'Content-Type' => 'application/json' }, body: JSON.generate({
      "requests": [{
        "image": { "content": base64_encoded },
        "features": [
          { "type": "CROP_HINTS", "maxResults": 5 }
        ]
      }]
    }))

    response.parsed_response.dig("responses", 0, "cropHintsAnnotation", "cropHints", 0, "boundingPoly", "vertices") # Return the parsed JSON response
  end
end