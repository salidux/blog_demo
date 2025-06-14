class RemoveAverageTimeSpentFromPostAnalytics < ActiveRecord::Migration[7.2]
  def change
    remove_column :post_analytics, :average_time_spent, :integer
  end
end
