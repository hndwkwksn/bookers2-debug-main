class Group < ApplicationRecord
  has_many :group_users, dependent: :destroy, foreign_key: 'group_id'
  has_many :users, through: :group_users
end
