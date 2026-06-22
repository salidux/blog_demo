class Post < ApplicationRecord
  validates :title, presence: true, length: { minimum: 3 }
  validates :content, presence: true
  validates :published, inclusion: { in: [ true, false ] }

  has_one :post_analytics, dependent: :destroy

  # Net reaction score, computed on read so it can never drift from its inputs.
  def score
    like_count - dislike_count
  end

  # Record a reaction with an atomic SQL increment so concurrent reactions are
  # never lost (unlike a read-modify-write via increment!).
  def like!
    self.class.increment_counter(:like_count, id)
  end

  def dislike!
    self.class.increment_counter(:dislike_count, id)
  end
end
