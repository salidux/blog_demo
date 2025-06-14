require "test_helper"

class StatsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @post_with_analytics = Post.create!(
      title: "Post with Analytics",
      content: "This is a post with some analytics data.",
      published: true
    )
    @post_with_analytics.create_post_analytics!(
      view_count: 10,
      reading_time: 2,
      last_viewed_at: 1.hour.ago
    )

    @post_without_analytics = Post.create!(
      title: "Post without Analytics",
      content: "This post has no analytics data yet.",
      published: false
    )
  end

  test "should get index" do
    get stats_url
    assert_response :success
  end

  test "displays posts with analytics data" do
    get stats_url

    assert_select "h1", "Post Statistics"
    assert_select "table"

    # Check that post with analytics is displayed
    assert_select "td", text: /Post with Analytics/
    assert_select "td", text: /10.*views/
    assert_select "td", text: /2.*min read/

    # Check that post without analytics is also displayed (with zero values)
    assert_select "td", text: /Post without Analytics/
    assert_select "td", text: /0.*views/
  end

  test "displays summary statistics" do
    get stats_url

    assert_select ".stats-summary"
    assert_select ".summary-cards"
    assert_select "h4", "Total Posts"
    assert_select "h4", "Total Views"
    assert_select "h4", "Avg Reading Time"
  end

  test "displays empty state when no posts exist" do
    Post.destroy_all

    get stats_url

    assert_select ".empty-state", text: /No posts found/
    assert_select "a", text: "Create your first post"
  end

  test "orders posts by view count descending" do
    # Create another post with higher view count
    high_view_post = Post.create!(
      title: "High View Post",
      content: "This post has many views.",
      published: true
    )
    high_view_post.create_post_analytics!(
      view_count: 50,
      reading_time: 3,
      last_viewed_at: 30.minutes.ago
    )

    get stats_url

    # Check that posts are ordered by view count (high to low)
    response_body = response.body
    high_view_index = response_body.index("High View Post")
    regular_view_index = response_body.index("Post with Analytics")

    assert high_view_index < regular_view_index, "Posts should be ordered by view count descending"
  end
end
