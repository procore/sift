require 'test_helper'

class FiltratorTest < ActiveSupport::TestCase
  test 'it takes a collection, params and (optional) filters' do
    Filterable::Filtrator.new(Post.all, { id: 1 }, [])
  end

  test 'it filters by all the filters you pass it' do
    post = Post.create!
    filter = Filterable::Filter.new(:id, :int)

    collection = Filterable::Filtrator.filter(Post.all, { id: post.id }, [filter])

    assert_equal Post.where(id: post.id), collection
  end
end
