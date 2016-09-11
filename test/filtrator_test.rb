require 'test_helper'

class FiltratorTest < ActiveSupport::TestCase
  test 'it takes a collection, params and filters' do
    Filtrator.new(Post.all, { id: 1}, [])
  end
end
