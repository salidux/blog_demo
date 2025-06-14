class Post < ApplicationRecord
  validates :title, presence: true, length: { minimum: 3 }
  validates :content, presence: true
  validates :published, inclusion: { in: [ true, false ] }
end
