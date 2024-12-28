class Device < ApplicationRecord
  belongs_to :user
  has_many :image_groups

  def is_portrait
    self.height > self.width
  end
end
