require 'test_helper'

class FilterableTest < ActiveSupport::TestCase
  class MyClass
    include Filterable

    def params
      ActionController::Parameters.new({})
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

  test "filtrate applies the filters" do
    MyClass.filter_on(:id, type: :int)

    assert_equal [], MyClass.new.filtrate(Post.all)
  end
end
