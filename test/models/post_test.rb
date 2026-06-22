require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "should not save post without title" do
    post = Post.new(content: "Some content", published: false)
    assert_not post.save
  end

  test "should not save post with short title" do
    post = Post.new(title: "Hi", content: "Some content", published: false)
    assert_not post.save
  end

  test "should not save post without content" do
    post = Post.new(title: "Valid Title", published: false)
    assert_not post.save
  end

  test "should save valid post" do
    post = Post.new(title: "Valid Title", content: "Some content", published: false)
    assert post.save
  end

  test "score returns likes minus dislikes" do
    post = Post.new(title: "Valid Title", content: "Some content", published: true, like_count: 7, dislike_count: 2)
    assert_equal 5, post.score
  end

  test "score can be negative" do
    post = Post.new(title: "Valid Title", content: "Some content", published: true, like_count: 1, dislike_count: 4)
    assert_equal(-3, post.score)
  end

  test "new post defaults to zero counts and score" do
    post = Post.create!(title: "Valid Title", content: "Some content", published: false)
    assert_equal 0, post.like_count
    assert_equal 0, post.dislike_count
    assert_equal 0, post.score
  end
end
