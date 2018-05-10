require "test_helper"

class FiltratorTest < ActiveSupport::TestCase
  test "it takes a collection, params and (optional) filters" do
    Brita::Filtrator.new(Post.all, { id: 1 }, [])
  end

  test "it filters by all the filters you pass it" do
    post = Post.create!
    filter = Brita::Filter.new(:id, :int, :id, nil)

    collection = Brita::Filtrator.filter(
      Post.all,
      { filters: { id: post.id } },
      [filter],
    )

    assert_equal Post.where(id: post.id), collection
  end

  test "it will not try to make a range out of a string field that includes ..." do
    post = Post.create!(title: "wow...man")
    filter = Brita::Filter.new(:title, :string, :title, nil)

    collection = Brita::Filtrator.filter(
      Post.all,
      { filters: { title: post.title } },
      [filter],
    )

    assert_equal Post.where(id: post.id).to_a, collection.to_a
  end

  test "it returns default when filter param not passed" do
    Post.create!(body: "foo")
    Post.create!(body: "bar")
    filter = Brita::Filter.new(:body2, :scope, :body2, ->(c) { c.order(:body) })
    collection = Brita::Filtrator.filter(Post.all, {}, [filter])

    assert_equal [Post.second, Post.first], collection.to_a
  end

  test "it will not return default if param passed" do
    Post.create!(body: "foo")
    filtered_post = Post.create!(body: "bar")
    filter = Brita::Filter.new(:body2, :scope, :body2, nil)
    collection = Brita::Filtrator.filter(
      Post.all,
      { filters: { body2: "bar" } },
      [filter],
    )

    assert_equal Post.where(id: filtered_post.id).to_a, collection.to_a
  end

  test "it can filter on scopes that need values from params" do
    Post.create!(priority: 5, expiration: "2017-01-01")
    Post.create!(priority: 5, expiration: "2017-01-02")
    Post.create!(priority: 7, expiration: "2020-10-20")
    filter = Brita::Filter.new(
      :expired_before_and_priority,
      :scope,
      :expired_before_and_priority,
      nil,
      nil,
      [:priority],
    )
    collection = Brita::Filtrator.filter(
      Post.all,
      { filters: { expired_before_and_priority: "2017-12-31" }, priority: 5 },
      [filter],
    )

    assert_equal 3, Post.count
    assert_equal 2, Post.expired_before_and_priority("2017-12-31", priority: 5).count
    assert_equal 2, collection.count

    assert_equal(
      Post.expired_before_and_priority("2017-12-31", priority: 5).to_a,
      collection.to_a,
    )
  end

  test "it can filter on scopes that need multiple values from params" do
    Post.create!(priority: 5, expiration: "2017-01-01")
    Post.create!(priority: 5, expiration: "2017-01-02")
    Post.create!(priority: 7, expiration: "2020-10-20")

    filter = Brita::Filter.new(
      :ordered_expired_before_and_priority,
      :scope,
      :ordered_expired_before_and_priority,
      nil,
      nil,
      [:date, :priority],
    )
    collection = Brita::Filtrator.filter(
      Post.all,
      {
        filters: { ordered_expired_before_and_priority: "ASC" },
        priority: 5,
        date: "2017-12-31"
      },
      [filter],
    )

    assert_equal 3, Post.count
    assert_equal 2, Post.ordered_expired_before_and_priority("ASC", date: "2017-12-31", priority: 5).count
    assert_equal 2, collection.count

    assert_equal Post.ordered_expired_before_and_priority("ASC", date: "2017-12-31", priority: 5).to_a, collection.to_a
  end

  test "it can sort on scopes that do not require arguments" do
    Post.create!(body: "zzzz")
    Post.create!(body: "aaaa")
    Post.create!(body: "ffff")
    sort = Brita::Sort.new(:body, :scope, :order_on_body_no_params)
    # scopes that take no param seem silly, as the user's designation of sort direction would be rendered useless
    # unless the controller does some sort of parsing on user's input and handles the sort on its own
    # nonetheless, Brita supports it :)
    collection = Brita::Filtrator.filter(Post.all, { sort: "-body" }, [sort])

    assert_equal Post.order_on_body_no_params.to_a, collection.to_a
  end

  test "it can sort on scopes that require one argument" do
    Post.create!(body: "zzzz")
    Post.create!(body: "aaaa")
    Post.create!(body: "ffff")
    sort = Brita::Sort.new(
      :body,
      :scope,
      :order_on_body_one_param,
      [:direction],
    )
    collection = Brita::Filtrator.filter(Post.all, { sort: "-body" }, [sort])

    assert_equal Post.order_on_body_one_param(:desc).to_a, collection.to_a
  end

  test "it can sort on scopes that require multiple arguments" do
    Post.create!(body: "zzzz")
    Post.create!(body: "aaaa")
    Post.create!(body: "ffff")
    sort = Brita::Sort.new(
      :body,
      :scope,
      :order_on_body_multi_param,
      ["aaaa", :direction],
    )
    collection = Brita::Filtrator.filter(Post.all, { sort: "-body" }, [sort])

    assert_equal Post.order_on_body_multi_param("aaaa", :desc).to_a, collection.to_a
  end

  test "it can sort on scopes that are passed a lambda" do
    Post.create!(body: "zzzz")
    Post.create!(body: "aaaa")
    Post.create!(body: "ffff")
    sort = Brita::Sort.new(
      :body,
      :scope,
      :order_on_body_multi_param,
      [lambda { "aaaa" }, :direction],
    )
    collection = Brita::Filtrator.filter(Post.all, { sort: "-body" }, [sort])

    assert_equal Post.order_on_body_multi_param("aaaa", :desc).to_a, collection.to_a
  end

  test "it can sort on scopes that require multiple dynamic arguments" do
    Post.create!(body: "zzzz", expiration: "2017-01-01")
    Post.create!(body: "aaaa", expiration: "2017-01-01")
    Post.create!(body: "ffff", expiration: "2020-10-20")
    sort = Brita::Sort.new(
      :dynamic_sort,
      :scope,
      :expired_before_ordered_by_body,
      [:date, :direction],
    )
    collection = Brita::Filtrator.filter(
      Post.all,
      { date: "2017-12-31", sort: "dynamic_sort", filters: {} },
      [sort],
    )

    assert_equal 3, Post.count
    assert_equal 2, Post.expired_before_ordered_by_body("2017-12-31", :asc).count
    assert Post.expired_before_ordered_by_body("2017-12-31", :asc).first.body == "aaaa"
    assert Post.expired_before_ordered_by_body("2017-12-31", :asc).last.body == "zzzz"

    assert_equal 2, collection.count

    assert collection.first.body == "aaaa"
    assert collection.last.body == "zzzz"

    assert_equal Post.expired_before_ordered_by_body("2017-12-31", :asc).to_a, collection.to_a
  end

  test "it can filter arrays" do
    post = Post.create!
    filter = Brita::Filter.new(:id, :int, :id, nil)
    posts = Post.all.map { |post| post.attributes }

    collection = Brita::Filtrator.filter(
      Brita::Collection.new(posts),
      { filters: { id: post.id } },
      [filter]
    )

    assert_equal posts.select { |item| item['id'] == post.id }, collection
  end
end
