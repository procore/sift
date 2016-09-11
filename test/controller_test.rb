require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  test 'it works' do
    Post.create!

    get('/posts')

    assert_equal 1, JSON.parse(@response.body).size
  end

  test 'it filters on id by value' do
    post = Post.create!
    Post.create!

    get('/posts', params: { filters: { id: post.id } })

    assert_equal 1, JSON.parse(@response.body).size
  end

  test 'it filters on decimals' do
    post = Post.create!(rating: 1.25)
    Post.create!

    get('/posts', params: { filters: { rating: post.rating } })

    assert_equal 1, JSON.parse(@response.body).size
  end

  test 'it filters on booleans' do
    post = Post.create!(visible: true)
    Post.create!

    get('/posts', params: { filters: { visible: '1' } })

    assert_equal 1, JSON.parse(@response.body).size
  end

  test 'it filters on booleans false' do
    post = Post.create!(visible: false)
    Post.create!

    get('/posts', params: { filters: { visible: '0' } })

    assert_equal 1, JSON.parse(@response.body).size
  end

  test 'it filters on id with a range' do
    post = Post.create!
    post2 = Post.create!
    Post.create!

    get('/posts', params: { filters: { id: "#{post.id}...#{post2.id}" } })

    assert_equal 2, JSON.parse(@response.body).size
  end

  test 'it filters on id with an array' do

  end
end
