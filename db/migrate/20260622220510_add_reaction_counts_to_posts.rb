class AddReactionCountsToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :like_count, :integer, default: 0, null: false
    add_column :posts, :dislike_count, :integer, default: 0, null: false
  end
end
