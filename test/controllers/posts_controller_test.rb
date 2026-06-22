require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
  end

  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "should get new" do
    get new_post_url
    assert_response :success
  end

  test "should create post" do
    assert_difference("Post.count") do
      post posts_url, params: { post: { title: "Test Post", content: "Test Content", published: true } }
    end

    assert_redirected_to post_url(Post.last)
  end

  test "should show post" do
    get post_url(@post)
    assert_response :success
  end

  test "should get edit" do
    get edit_post_url(@post)
    assert_response :success
  end

  test "should update post" do
    patch post_url(@post), params: { post: { title: "Updated Title", content: "Updated Content", published: true } }
    assert_redirected_to post_url(@post)
  end

  test "should destroy post" do
    assert_difference("Post.count", -1) do
      delete post_url(@post)
    end

    assert_redirected_to posts_url
  end

  test "like increments like_count and redirects back" do
    assert_difference -> { @post.reload.like_count }, 1 do
      post like_post_url(@post)
    end
    assert_response :redirect
  end

  test "dislike increments dislike_count and redirects back" do
    assert_difference -> { @post.reload.dislike_count }, 1 do
      post dislike_post_url(@post)
    end
    assert_response :redirect
  end

  test "repeated likes are unbounded (no dedup)" do
    assert_difference -> { @post.reload.like_count }, 3 do
      3.times { post like_post_url(@post) }
    end
  end

  test "index shows the score" do
    @post.update!(like_count: 10, dislike_count: 3)
    get posts_url
    assert_response :success
    assert_select "p.score", text: /Score: 7/
  end

  test "show page shows score, counts, and reaction controls" do
    @post.update!(like_count: 10, dislike_count: 3)
    get post_url(@post)
    assert_response :success
    assert_select "section.reactions" do
      assert_select "p.score", text: /Score: 7/
      assert_select "form[action=?]", like_post_path(@post)
      assert_select "form[action=?]", dislike_post_path(@post)
    end
  end
end
