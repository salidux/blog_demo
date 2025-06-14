require "test_helper"

class PostAnalyticsProcessorJobTest < ActiveJob::TestCase
  def setup
    @post = Post.create!(
      title: "Test Post",
      content: "This is a test post with some content to test reading time calculation. " * 10,
      published: true
    )
  end

  test "creates analytics record if none exists" do
    assert_nil @post.post_analytics

    PostAnalyticsProcessorJob.perform_now(@post.id)

    @post.reload
    assert_not_nil @post.post_analytics
    assert_equal 1, @post.post_analytics.view_count
    assert @post.post_analytics.reading_time > 0
    assert_not_nil @post.post_analytics.last_viewed_at
  end

  test "increments view count for existing analytics" do
    analytics = @post.create_post_analytics!(
      view_count: 5,
      reading_time: 2,
      last_viewed_at: 1.hour.ago
    )

    PostAnalyticsProcessorJob.perform_now(@post.id)

    analytics.reload
    assert_equal 6, analytics.view_count
  end

  test "calculates reading time based on content length" do
    # Test with short content (should be minimum 1 minute)
    short_post = Post.create!(
      title: "Short Post",
      content: "Short content",
      published: true
    )

    PostAnalyticsProcessorJob.perform_now(short_post.id)

    short_post.reload
    assert_equal 1, short_post.post_analytics.reading_time

    # Test with longer content
    long_content = "word " * 400  # 400 words should be ~2 minutes
    long_post = Post.create!(
      title: "Long Post",
      content: long_content,
      published: true
    )

    PostAnalyticsProcessorJob.perform_now(long_post.id)

    long_post.reload
    assert_equal 2, long_post.post_analytics.reading_time
  end

  test "updates last_viewed_at timestamp" do
    old_time = 1.day.ago
    analytics = @post.create_post_analytics!(
      view_count: 1,
      reading_time: 1,
      last_viewed_at: old_time
    )

    PostAnalyticsProcessorJob.perform_now(@post.id)

    analytics.reload
    assert analytics.last_viewed_at > old_time
  end
end
