require_relative "test_helper"

class BritaTest < ActiveSupport::TestCase
  class MyClass
    attr_writer :params
    include Brita

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

  test "it registers default sort with default_sort" do
    MyClass.reset_filters
    MyClass.default_sort(:id, direction: :asc)
    assert_equal ['id'], MyClass.default_sorts.map(&:sort_condition)
  end

  test "it registers multiple default sorts with default_sort" do
    MyClass.reset_filters
    MyClass.default_sort(:id, direction: :asc)
    MyClass.default_sort(:title, direction: :desc)
    assert_equal ['id', '-title'], MyClass.default_sorts.map(&:sort_condition)
  end

  test "it registers a default sort with a direction of ascending when direction is not specified" do
    MyClass.reset_filters
    MyClass.default_sort(:id)
    assert_equal [:asc], MyClass.default_sorts.map(&:direction)
  end

  test "it always allows sort parameters to flow through" do
    MyClass.reset_filters
    custom_sort = { sort: { attribute: "due_date", direction: "asc" } }
    my_class = MyClass.new
    my_class.params = custom_sort

    assert_equal [], my_class.filtrate(Post.all)
  end
end
