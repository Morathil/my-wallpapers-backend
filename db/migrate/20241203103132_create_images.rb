class CreateImages < ActiveRecord::Migration[8.0]
  def change
    create_enum :image_type, ["original", "cropped", "thumbnail"]

    create_table :images do |t|
      t.enum :image_type, enum_type: "image_type", null: false
      t.integer :width, null: false
      t.integer :height, null: false

      t.timestamps
    end
  end
end
