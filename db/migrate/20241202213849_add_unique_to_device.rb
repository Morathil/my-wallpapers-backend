class AddUniqueToDevice < ActiveRecord::Migration[8.0]
  def change
    add_index :devices, [:width, :height], unique: true
  end
end
