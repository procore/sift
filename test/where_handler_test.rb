require "test_helper"

class WhereHandlerTest < ActiveSupport::TestCase
  test "it handles non-array arguments" do
    post1 = Post.create!(priority: 6, expiration: "2017-01-01")
    Post.create!(priority: 5, expiration: "2017-01-02")
    post3 = Post.create!(priority: 6, expiration: "2020-10-20")
    handler = Sift::WhereHandler.new(
      "6",
      Sift::Parameter.new(:priority, :int)
    )

    assert_equal [post1.id, post3.id], handler.call(Post).pluck(:id)
  end

  test "it parses array arguments" do
    post1 = Post.create!(priority: 6, expiration: "2017-01-01")
    Post.create!(priority: 5, expiration: "2017-01-02")
    post3 = Post.create!(priority: 7, expiration: "2020-10-20")
    handler = Sift::WhereHandler.new(
      "[6,7]",
      Sift::Parameter.new(:priority, :int)
    )

    assert_equal [post1.id, post3.id], handler.call(Post).pluck(:id)
  end
end
