class Group < ApplicationRecord
  has_many :group_users, dependent: :destroy, foreign_key: 'group_id'
  has_many :users, through: :group_users
  has_one_attached :image

  def get_image
    (image.attached?) ? image : 'no_image.jpg'
  end
end
