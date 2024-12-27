class Device < ApplicationRecord
    belongs_to :user
    has_many :image_groups
end
