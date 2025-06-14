class PostAnalytics < ApplicationRecord
  belongs_to :post

  validates :view_count, numericality: { greater_than_or_equal_to: 0 }
  validates :reading_time, numericality: { greater_than_or_equal_to: 0 }
  validates :average_time_spent, numericality: { greater_than_or_equal_to: 0 }
end
