# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

image = Image.create!(image_type: Image.image_types[:original], width: 10, height: 10)
image.file.attach(io: File.open("./README.md"), filename: "file.jpg", content_type: "text/css")
ActiveStorage::Current.url_options = { host: "http://localhost:3000" }

docker compose up -d
redis-server
bundle exec sidekiq
VISUAL="code --wait" bin/rails credentials:edit

# Reset DB
- rake db:reset db:migrate

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