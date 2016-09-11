require 'test_helper'

class FiltratorTest < ActiveSupport::TestCase
  test 'it takes a collection, params and (optional) filters' do
    Filterable::Filtrator.new(Post.all, { id: 1 }, [])
  end

  test 'it can apply any filter with apply' do
    post = Post.create!
    filtrator = Filterable::Filtrator.new(Post.all, { id: post.id })
    filter = Filterable::Filter.new(:id, :int)
    filtrator.apply(filter)
  end
end
