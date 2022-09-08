class Book < ApplicationRecord
  belongs_to :user
  has_many :book_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :week_favorites, -> { where(created_at: ((Time.current.at_end_of_day - 6.day).at_beginning_of_day)..(Time.current.at_end_of_day)) }, class_name: "Favorite"
  has_many :view_counts, dependent: :destroy
  has_many :book_tags, dependent: :destroy
  has_many :tags, through: :book_tags

  validates :title, presence: true
  validates :body, presence: true, length: { maximum: 200 }

  scope :created_today, -> { where(created_at: Time.zone.now.all_day) } # 今日
  scope :created_yesterday, -> { where(created_at: 1.day.ago.all_day) } # 前日
  scope :created_this_week, -> { where(created_at: 6.day.ago.beginning_of_day..Time.zone.now.end_of_day) } # 今週
  scope :created_last_week, -> { where(created_at: 2.week.ago.beginning_of_day..1.week.ago.end_of_day) } # 先週

  scope :created_2days, -> { where(created_at: 2.days.ago.all_day) }
  scope :created_3days, -> { where(created_at: 3.days.ago.all_day) }
  scope :created_4days, -> { where(created_at: 4.days.ago.all_day) }
  scope :created_5days, -> { where(created_at: 5.days.ago.all_day) }
  scope :created_6days, -> { where(created_at: 6.days.ago.all_day) }

  def favorited_by?(user)
    favorites.where(user_id: user.id).exists?
  end

  def save_tags(savebook_tags)
    current_tags = self.tags.pluck(:name) unless self.tags.nil? # 現在のユーザーの持っているskillを引っ張ってきている
    old_tags = current_tags - savebook_tags # 今bookが持っているタグと今回保存されたものの差をすでにあるタグとする。古いタグは消す。
    new_tags = savebook_tags - current_tags # 今回保存されたものと現在の差を新しいタグとする。新しいタグは保存

    # Destroy old taggings:
    old_tags.each do |old_name|
      self.tags.delete Tag.find_by(name: old_name)
    end

    # Create new taggings:
    new_tags.each do |new_name|
      book_tag = Tag.find_or_create_by(name: new_name)
      self.tags << book_tag # 配列に保存
    end
  end

  # 検索方法分岐
  def self.search_for(content, method)
    if method == "perfect"
      Book.where(title: content)
    elsif method == "forward"
      Book.where("title LIKE ?", content + "%")
    elsif method == "backward"
      Book.where("title LIKE ?", "%" + content)
    else
      @book = Book.where("title LIKE ?", "%" + content + "%")
    end
  end
end
