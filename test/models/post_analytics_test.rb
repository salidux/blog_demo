require "test_helper"

class PostAnalyticsTest < ActiveSupport::TestCase
  def setup
    @post = Post.create!(title: "Test Post", content: "Test content", published: true)
    @analytics = PostAnalytics.create!(
      post: @post,
      view_count: 0,
      reading_time: 1,
      average_time_spent: 0
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

  test "average_time_spent should be non-negative" do
    @analytics.average_time_spent = -1
    assert_not @analytics.valid?
  end
end
