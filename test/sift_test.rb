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

  test "Sift#active_model_filter_errors returns an ActiveModel::Error object" do
    MyClass.reset_filters
    my_class = MyClass.new

    assert_instance_of ActiveModel::Errors, my_class.active_model_filter_errors
    assert_equal my_class.active_model_filter_errors.messages, my_class.filter_errors
  end
end
