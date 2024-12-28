# My Wallpapers API Server (in Development)
This repository hosts the Rails API-only server for the My Wallpapers App.
The server is designed to handle authentication, device management, and image processing tasks.  
Here's an overview of the server's functionality:

### Features
#### Authentication
- Devise is used for user authentication and authorization.
- Stateless authentication is enabled via devise-jwt for secure API token management.
#### Device and Image Group Management
- Users can create devices through the API.
- Each device can have multiple image groups.
  - An image group consists of three images:
    - Original: Uploaded by the user.
    - Cropped: Generated based on crop hints from the Google Vision API.
    - Thumbnail: A smaller version of the image for efficient display.
#### Asynchronous Processing
- Sidekiq is used for background jobs to handle the following tasks asynchronously:
  - Generating cropped and thumbnail images after an original image is uploaded.
  - Fetching crop hints from the Google Vision API to optimize cropping.
#### Image Processing
- Images are processed using ruby-vips, providing efficient and high-quality operations.
- Cropping is based on crop hints provided by Google Vision API to ensure the most relevant part of the image is retained.
#### Image Storage
- All images are stored and managed via Active Storage.

## Start
- `redis-server`
- `docker-compose up -d`
- `rails s`
- `bundle exec sidekiq`

## Prerequisites
- `bundle install`
- `rails db:create db:migrate`
- `bundle exec rails secret` // devise_jwt_secret_key
- `VISUAL="code --wait" bin/rails credentials:edit`
  - Add: `devise_jwt_secret_key: (copy and paste the generated secret here)`
  - Add: `google_cloud_api_key: (get from google cloud console)`

## Postman
- Import `My Wallpapers.postman_collection.json`

## Google Vision Example Response
```
{
  "responses": [
    {
      "cropHintsAnnotation": {
        "cropHints": [
          {
            "boundingPoly": {
              "vertices": [
                {
                  "x": 2449
                },
                {
                  "x": 4897
                },
                {
                  "x": 4897,
                  "y": 3264
                },
                {
                  "x": 2449,
                  "y": 3264
                }
              ]
            },
            "confidence": 0.59375,
            "importanceFraction": 0.9410803
          }
        ]
      }
    }
  ]
}
```

## Reset DB
- `rake db:reset db:migrate`