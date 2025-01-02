class Device < ApplicationRecord
  belongs_to :user
  has_many :image_groups

  def portrait?
    self.height > self.width
  end
end
