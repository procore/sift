require 'test_helper'

class FilterableTest < ActiveSupport::TestCase
  class MyClass
    attr_accessor :params
    include Filterable

    def params
      @params ||= ActionController::Parameters.new({})
    end
  end

  test "does nothing if no filters are registered" do
    MyClass.reset_filters
    assert_equal [], MyClass.new.filtrate(Post.all)
  end

  test "it registers filters with filter_on" do
    MyClass.reset_filters
    MyClass.filter_on(:id, type: :int)

    assert_equal [:id], MyClass.filters.map(&:param)
  end

  test "it registers sorts with sort_on" do
    MyClass.reset_filters
    MyClass.sort_on(:id, type: :int)

    assert_equal [:id], MyClass.filters.map(&:param)
  end

  test "it always allows sort parameters to flow through" do
    MyClass.reset_filters
    custom_sort = { sort: { attribute: "due_date", direction: "asc" } }
    my_class = MyClass.new
    my_class.params = custom_sort

    assert_equal [], my_class.filtrate(Post.all)
  end

  test "it sorts on string keys" do
    Post.create!
    Post.create!
    MyClass.reset_filters
    MyClass.sort_on(:id, type: :int)
    descending = MyClass.new
    descending.params = { 'sort' => '-id' }
    ascending = MyClass.new
    ascending.params = { 'sort' => 'id' }

    assert_equal  Post.order(id: :desc), descending.filtrate(Post.all)
    assert_equal Post.order(id: :asc), ascending.filtrate(Post.all)
  end

  test "it sorts on symbol keys" do
    Post.create!
    Post.create!
    MyClass.reset_filters
    MyClass.sort_on(:id, type: :int)
    descending = MyClass.new
    descending.params = { sort: '-id' }
    ascending = MyClass.new
    ascending.params = { sort: 'id' }

    assert_equal Post.order(id: :desc), descending.filtrate(Post.all)
    assert_equal Post.order(id: :asc), ascending.filtrate(Post.all)
  end
end
