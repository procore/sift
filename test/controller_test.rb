require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  test 'it works' do
    post = Post.create!

    get('/posts')

    json = JSON.parse(@response.body)
    assert_equal 1, json.size
    assert_equal(post.id, json.first['id'])
  end

  test 'it filters on id by value' do
    post = Post.create!
    Post.create!

    get('/posts', params: { filters: { id: post.id } })

    json = JSON.parse(@response.body)
    assert_equal 1, json.size
    assert_equal post.id, json.first["id"]
  end

  test 'it filters on decimals' do
    post = Post.create!(rating: 1.25)
    Post.create!

    get('/posts', params: { filters: { rating: post.rating } })

    json = JSON.parse(@response.body)
    assert_equal 1, json.size
    assert_equal post.id, json.first["id"]
  end

  test 'it filters on booleans' do
    post = Post.create!(visible: true)
    Post.create!

    get('/posts', params: { filters: { visible: '1' } })

    json = JSON.parse(@response.body)
    assert_equal 1, json.size
    assert_equal post.id, json.first["id"]
  end

  test 'it filters on booleans false' do
    post = Post.create!(visible: false)
    Post.create!

    get('/posts', params: { filters: { visible: '0' } })

    json = JSON.parse(@response.body)
    assert_equal 1, json.size
    assert_equal post.id, json.first["id"]
  end

  test 'it invalidates id' do
    Post.create!(visible: false)
    Post.create!
    expected_json = { 'errors' => { 'id' => ['must be int or range'] } }


    get('/posts', params: { filters: { id: 'poopie' } })

    json = JSON.parse(@response.body)

    assert_equal expected_json, json
  end

  test 'it filters on id with a range' do
    post = Post.create!
    post2 = Post.create!
    Post.create!

    get('/posts', params: { filters: { id: "#{post.id}...#{post2.id}" } })

    json = JSON.parse(@response.body)
    assert_equal 2, json.size
  end

  test 'it filters on id with an array' do

  end

  test 'it filters on named scope' do
    Post.create!(expiration: 3.days.ago)
    Post.create!(expiration: 1.days.ago)
    get('/posts', params: { filters: { expired_before: 2.days.ago } })

    json = JSON.parse(@response.body)
    assert_equal 1, json.size
  end

  test 'the param can have a different name from the internal name' do
    post = Post.create!(title: 'hi')
    Post.create!(title: 'friend')
    get('/posts', params: { filters: { french_bread: post.title } })

    json = JSON.parse(@response.body)
    assert_equal 1, json.size
  end

  test 'it sorts' do
    Post.create!(title: 'z')
    Post.create!(title: 'a')

    get('/posts', params: { sort: 'title' })

    json = JSON.parse(@response.body, object_class: OpenStruct)
    assert_equal ['a', 'z'], json.map(&:title)
  end

  test 'it sorts descending' do
    Post.create!(title: 'z')
    Post.create!(title: 'a')

    get('/posts', params: { sort: '-title' })

    json = JSON.parse(@response.body, object_class: OpenStruct)
    assert_equal ['z', 'a'], json.map(&:title)
  end

  test 'it can do multiple sorts' do
    Post.create!(title: 'z')
    Post.create!(title: 'g', priority: 1)
    Post.create!(title: 'g', priority: 10)
    Post.create!(title: 'a')

    get('/posts', params: { sort: '-title,-priority' })

    json = JSON.parse(@response.body, object_class: OpenStruct)
    assert_equal ['z', 'g', 'g', 'a'], json.map(&:title)
    assert_equal [nil, 10, 1, nil], json.map(&:priority)
  end

  test 'it errors on unknown fields' do
    expected_json = {"errors"=>{"sort"=>["is not included in the list"]}}

    get('/posts', params: { sort: '-not-there' })

    json = JSON.parse(@response.body)
    assert_equal expected_json, json
  end

  test 'it custom filters' do
    post = Post.create!
    Post.create!

    get('/posts', params: { filters: { id_array: [post.id] } })
    json = JSON.parse(@response.body)
    assert_equal 1, json.size
    assert_equal post.id, json.first["id"]
  end
  
  test 'it respects custom validation logic' do
    expected_json = {"errors"=>{"id_array"=>["Not all values were valid integers"]}}
    post = Post.create!
    Post.create!

    get('/posts', params: { filters: { id_array: [post.id, "zebra"] } })
    json = JSON.parse(@response.body)
    assert_equal json, expected_json
  end

  test "it sorts on string keys" do
    Post.create!(title: 'a')
    Post.create!(title: 'b')
    Post.create!(title: 'z')
    get('/posts', params: { 'sort' => '-title' })
    json = JSON.parse(@response.body, object_class: OpenStruct)
    assert_equal ['z', 'b', 'a'], json.map(&:title)
  end

  test "it sorts on symbol keys" do
    Post.create!(title: 'a')
    Post.create!(title: 'b')
    Post.create!(title: 'z')
    get('/posts', params: { sort: '-title' })
    json = JSON.parse(@response.body, object_class: OpenStruct)
    assert_equal ['z', 'b', 'a'], json.map(&:title)
  end

  test 'it sorts case-insensitively on text/string types' do
    Post.create(title: 'b')
    Post.create(title: 'A')
    Post.create(title: 'C')
    Post.create(title: 'd')
    get('/posts', params: { sort: 'title' })
    json = JSON.parse(@response.body, object_class: OpenStruct)
    assert_equal ['A', 'b', 'C', 'd'], json.map(&:title)
  end

  test 'it respects internal name for non-scope sorts' do
    Post.create(title: 'b')
    Post.create(title: 'A')
    Post.create(title: 'C')
    Post.create(title: 'd')
    get('/posts', params: { sort: 'foobar' })
    json = JSON.parse(@response.body, object_class: OpenStruct)
    assert_equal ['A', 'b', 'C', 'd'], json.map(&:title)
  end

  test 'it sorts with dependent params' do
    Post.create(body: 'b', expiration: "2017-11-11")
    Post.create(body: 'A', expiration: "2017-10-10")
    Post.create(body: 'C', expiration: "2090-08-08")
    get('/posts', params: { sort: 'dynamic_sort', date: "2017-12-12" })
    json = JSON.parse(@response.body)
    assert_equal ['A', 'b'], json.map { |post| post.fetch("body") }
  end

  test 'it filters with dependent params' do
    Post.create(priority: 7, expiration: "2017-11-11")
    Post.create(priority: 3, expiration: "2017-10-10")
    get('/posts', params: { filters: { expired_before_and_priority: "2017-12-12"}, priority: 5})
    json = JSON.parse(@response.body)
    assert_equal [3], json.map { |post| post.fetch("priority") }
  end
end
