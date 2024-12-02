class AddWidthToDevices < ActiveRecord::Migration[8.0]
  def change
    add_column :devices, :width, :integer
    add_column :devices, :height, :integer
  end
end
