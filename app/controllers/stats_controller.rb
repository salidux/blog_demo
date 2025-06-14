class StatsController < ApplicationController
  def index
    # Get all posts with their analytics, ordered by view count descending
    @posts_with_analytics = Post.joins("LEFT JOIN post_analytics ON posts.id = post_analytics.post_id")
                               .select("posts.*,
                                       COALESCE(post_analytics.view_count, 0) as view_count,
                                       COALESCE(post_analytics.reading_time, 0) as reading_time,
                                       post_analytics.last_viewed_at")
                               .order("view_count DESC, posts.created_at DESC")
  end
end
