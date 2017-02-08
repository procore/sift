require 'test_helper'

class FiltratorTest < ActiveSupport::TestCase
  test 'it takes a collection, params and (optional) filters' do
    Filterable::Filtrator.new(Post.all, { id: 1 }, [])
  end

  test 'it filters by all the filters you pass it' do
    post = Post.create!
    filter = Filterable::Filter.new(:id, :int, :id, nil)

    collection = Filterable::Filtrator.filter(Post.all, { id: post.id }, [filter])

    assert_equal Post.where(id: post.id), collection
  end

  test 'it will not try to make a range out of a string field that includes ...' do
    post = Post.create!(title: 'wow...man')
    filter = Filterable::Filter.new(:title, :string, :title, nil)

    collection = Filterable::Filtrator.filter(Post.all, { title: post.title }, [filter])

    assert_equal Post.where(id: post.id).to_a, collection.to_a
  end

  test 'it returns default when filter param not passed' do
    Post.create!(body: "foo")
    Post.create!(body: "bar")
    filter = Filterable::Filter.new(:body2, :scope, :body2, ->(c) { c.order(:body) })
    collection = Filterable::Filtrator.filter(Post.all, {}, [filter])

    assert_equal [Post.second, Post.first], collection.to_a
  end

  test 'it will not return default if param passed' do
    Post.create!(body: "foo")
    filtered_post = Post.create!(body: "bar")
    filter = Filterable::Filter.new(:body2, :scope, :body2, nil)
    collection = Filterable::Filtrator.filter(Post.all, { body2: "bar" }, [filter])

    assert_equal Post.where(id: filtered_post.id).to_a, collection.to_a
  end

  test 'it can filter on scopes that accept multiple arguments' do
    Post.create!(body: "foo", priority: 1)
    Post.create!(body: "bar", priority: 10)
    filtered_post = Post.create!(body: "foo", priority: 10)
    filter = Filterable::Filter.new(:body_and_priority, :scope, :body_and_priority, nil)
    collection = Filterable::Filtrator.filter(Post.all, { body_and_priority: ["foo", 10] }, [filter])

    assert_equal Post.where(id: filtered_post.id).to_a, collection.to_a
  end

  test 'it can sort on scopes that do not require arguments' do
    Post.create!(body: 'zzzz')
    Post.create!(body: 'aaaa')
    Post.create!(body: 'ffff')
    sort = Filterable::Sort.new(:body, :scope, :order_on_body_no_params)
    # scopes that take no param seem silly, as the user's designation of sort direction would be rendered useless
    # unless the controller does some sort of parsing on user's input and handles the sort on its own
    # nonetheless, Filterable supports it :)
    collection = Filterable::Filtrator.filter(Post.all, {}, [sort], ['-body'])

    assert_equal Post.order_on_body_no_params.to_a, collection.to_a
  end

  test 'it can sort on scopes that require one argument' do
    Post.create!(body: 'zzzz')
    Post.create!(body: 'aaaa')
    Post.create!(body: 'ffff')
    sort = Filterable::Sort.new(:body, :scope, :order_on_body_one_param, [:direction])
    collection = Filterable::Filtrator.filter(Post.all, {}, [sort], ['-body'])

    assert_equal Post.order_on_body_one_param(:desc).to_a, collection.to_a
  end

  test 'it can sort on scopes that require multiple arguments' do
    Post.create!(body: 'zzzz')
    Post.create!(body: 'aaaa')
    Post.create!(body: 'ffff')
    sort = Filterable::Sort.new(:body, :scope, :order_on_body_multi_param, ['aaaa', :direction])
    collection = Filterable::Filtrator.filter(Post.all, {}, [sort], ['-body'])

    assert_equal Post.order_on_body_multi_param('aaaa', :desc).to_a, collection.to_a
  end

  test 'it can sort on scopes that are passed a lambda' do
    Post.create!(body: 'zzzz')
    Post.create!(body: 'aaaa')
    Post.create!(body: 'ffff')
    sort = Filterable::Sort.new(:body, :scope, :order_on_body_multi_param, [lambda { 'aaaa' }, :direction])
    collection = Filterable::Filtrator.filter(Post.all, {}, [sort], ['-body'])

    assert_equal Post.order_on_body_multi_param('aaaa', :desc).to_a, collection.to_a
  end
end
