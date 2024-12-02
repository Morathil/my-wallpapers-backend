class AddNullConstraintToWidthToDevices < ActiveRecord::Migration[8.0]
  def change
    change_column :devices, :width, :integer, null: false
    change_column :devices, :height, :integer, null: false
  end
end
