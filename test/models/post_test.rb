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

  # test "the truth" do
  #   assert true
  # end
end
