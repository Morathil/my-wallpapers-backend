class CreateImageGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :image_groups do |t|
      t.timestamps
    end
  end
end
