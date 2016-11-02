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

  test 'it will clear default order if sort param is passed in' do
    Post.create!(body: "foo")
    Post.create!(body: "bar")
    filter = Filterable::Sort.new(:body, :string, :body)
    collection = Filterable::Filtrator.filter(Post.all.order(:id), {}, [filter], ['body'])

    assert_equal [Post.second, Post.first], collection.to_a
  end
end
