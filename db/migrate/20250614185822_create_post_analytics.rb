class CreatePostAnalytics < ActiveRecord::Migration[7.2]
  def change
    create_table :post_analytics do |t|
      t.references :post, null: false, foreign_key: true
      t.integer :view_count
      t.integer :reading_time
      t.datetime :last_viewed_at
      t.integer :average_time_spent

      t.timestamps
    end
  end
end
