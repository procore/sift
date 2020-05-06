require "test_helper"

class ScopeHandlerTest < ActiveSupport::TestCase
  test "it passes values as strings without scope types" do
    post1 = Post.create!(priority: 6, expiration: "2017-01-01")
    Post.create!(priority: 5, expiration: "2017-01-02")
    Post.create!(priority: 6, expiration: "2020-10-20")
    handler = Sift::ScopeHandler.new(
      "2020-09-01",
      { priority: "6" },
      Sift::Parameter.new(:expired_before_and_priority, :scope),
      []
    )

    assert_equal [post1.id], handler.call(Post).pluck(:id)
  end

  test "it parses values using scope types" do
    post1 = Post.create!(priority: 6, expiration: "2017-01-01")
    post2 = Post.create!(priority: 5, expiration: "2017-01-02")
    Post.create!(priority: 6, expiration: "2020-10-20")
    handler = Sift::ScopeHandler.new(
      "2020-09-01",
      { priority: "[5,6]" },
      Sift::Parameter.new(:expired_before_and_priority, :scope),
      [:datetime, { priority: :int }]
    )

    assert_equal [post1.id, post2.id], handler.call(Post).pluck(:id)
  end
end
