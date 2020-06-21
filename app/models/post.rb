class Post < ApplicationRecord
  # include Redis::Objects
  validates :title, presence: true
  validates :content, presence: true
  belongs_to :user
  include Redis::Objects

  def created_time
    self.created_at.strftime("%Y/%m/%d")
  end
end
