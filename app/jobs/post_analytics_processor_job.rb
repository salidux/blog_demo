class PostAnalyticsProcessorJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    post = Post.find(post_id)
    analytics = post.post_analytics || post.create_post_analytics(
      view_count: 0,
      reading_time: 0,
      last_viewed_at: Time.current
    )

    # Increment view count
    analytics.increment!(:view_count)

    # Calculate reading time based on content length
    # Average reading speed is approximately 200 words per minute
    word_count = post.content.split.length
    reading_time_minutes = (word_count / 200.0).ceil
    reading_time_minutes = 1 if reading_time_minutes < 1 # Minimum 1 minute

    analytics.update!(
      reading_time: reading_time_minutes,
      last_viewed_at: Time.current
    )

    Rails.logger.info "Analytics processed for post #{post.id}: #{analytics.view_count} views, #{analytics.reading_time} min read time"
  end
end
