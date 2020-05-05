require "test_helper"

class SiftTest < ActiveSupport::TestCase
  class MyClass
    attr_writer :params
    include Sift

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

  test "it defaults scope params to scope subtypes" do
    MyClass.reset_filters
    MyClass.filter_on(:foo, type: { scope: [:string, { bar: :int, biz: :string }] })

    assert_equal [:bar, :biz], MyClass.filters.first.scope_params
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
end
