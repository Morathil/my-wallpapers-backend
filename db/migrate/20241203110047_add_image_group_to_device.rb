class AddImageGroupToDevice < ActiveRecord::Migration[8.0]
  def change
    add_reference :image_groups, :original, null: false, foreign_key: { to_table: :images }
    add_reference :image_groups, :cropped, null: true, foreign_key: { to_table: :images }
    add_reference :image_groups, :thumbnail, null: true, foreign_key: { to_table: :images }

    add_reference :image_groups, :device, null: false, foreign_key: true
  end
end
