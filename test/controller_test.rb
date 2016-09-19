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
end
