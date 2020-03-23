require "test_helper"

class PostsInheritanceTest < ActionDispatch::IntegrationTest
  test "it works" do
    post = Post.create!

    get("/posts_alt")

    json = JSON.parse(@response.body)
    assert_equal 1, json.size
    assert_equal(post.id, json.first["id"])
  end

  test "it inherits filter from parent controller" do
    post = Post.create!
    Post.create!

    get("/posts_alt", params: { filters: { id: post.id } })

    json = JSON.parse(@response.body)
    assert_equal 1, json.size
    assert_equal post.id, json.first["id"]
  end

  test "it inherits sort from parent controller" do
    Post.create!(title: "z")
    Post.create!(title: "a")

    get("/posts_alt", params: { sort: "title" })

    json = JSON.parse(@response.body, object_class: OpenStruct)
    assert_equal ["a", "z"], json.map(&:title)
  end

  test "it overrides filter from parent controller" do
    Post.create!(body: "hi")
    Post.create!(body: "hello")
    Post.create!(body: "hola")
    get("/posts_alt", params: { filters: { french_bread: ["hi", "hello"] } })

    json = JSON.parse(@response.body)
    assert_equal 2, json.size
  end

  test "it overrides sort from parent controller" do
    Post.create!(priority: 3)
    Post.create!(priority: 1)
    Post.create!(priority: 2)
    get("/posts_alt", params: { sort: "foobar" })

    json = JSON.parse(@response.body, object_class: OpenStruct)
    assert_equal [1, 2, 3], json.map(&:priority)
  end
end
