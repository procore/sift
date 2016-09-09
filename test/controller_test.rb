require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest

  test 'it works' do
    Post.create!

    get('/posts')

    assert_equal 1, JSON.parse(@response.body).size
  end

  test 'it filters on id' do
    post = Post.create!

    get('/posts', params: {filters: { id: post.id }})

    assert_equal 1, JSON.parse(@response.body).size
  end
end
