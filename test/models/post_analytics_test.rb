require "test_helper"

class PostAnalyticsTest < ActiveSupport::TestCase
  def setup
    @post = Post.create!(title: "Test Post", content: "Test content", published: true)
    @analytics = PostAnalytics.create!(
      post: @post,
      view_count: 0,
      reading_time: 1
    )
  end

  test "should be valid" do
    assert @analytics.valid?
  end

  test "should require a post" do
    @analytics.post = nil
    assert_not @analytics.valid?
  end

  test "view_count should be non-negative" do
    @analytics.view_count = -1
    assert_not @analytics.valid?
  end

  test "reading_time should be non-negative" do
    @analytics.reading_time = -1
    assert_not @analytics.valid?
  end

  test "should allow zero values for view_count and reading_time" do
    @analytics.view_count = 0
    @analytics.reading_time = 0
    assert @analytics.valid?
  end

  test "should update last_viewed_at timestamp" do
    old_time = 1.day.ago
    @analytics.last_viewed_at = old_time
    @analytics.save!

    new_time = Time.current
    @analytics.update!(last_viewed_at: new_time)

    assert @analytics.last_viewed_at > old_time
  end
end
