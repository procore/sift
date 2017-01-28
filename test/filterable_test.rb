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

  test "it only sorts on scope if specified" do
    Post.create(body: 'bbbbbb')
    Post.create(body: 'zzzzzz')
    Post.create(body: 'aaaaaa')
    Post.create(body: 'cccccc')
    MyClass.reset_filters
    MyClass.sort_on(:body, type: :scope, internal_name: :order_on_body_no_params)
    MyClass.sort_on(:id, type: :int)
    my_class = MyClass.new
    my_class.params = { sort: '-id' }

    assert_equal my_class.filtrate(Post.all), Post.order(id: :desc)
  end

  test "it sorts on scopes with no params" do
    Post.create(body: 'bbbbbb')
    Post.create(body: 'zzzzzz')
    Post.create(body: 'aaaaaa')
    Post.create(body: 'cccccc')
    MyClass.reset_filters
    MyClass.sort_on(:body, type: :scope, internal_name: :order_on_body_no_params)
    my_class = MyClass.new

    # scopes that take no param seem silly, as the user's designation of sort direction would be rendered useless
    # unless the controller does some sort of parsing on user's input and handles the sort on its own
    # nonetheless, Filterable supports it :)
    my_class.params = { sort: '-body' }

    assert_equal my_class.filtrate(Post.all), Post.order_on_body_no_params
  end

  test "it sorts on scopes with one param" do
    Post.create(body: 'bbbbbb')
    Post.create(body: 'zzzzzz')
    Post.create(body: 'aaaaaa')
    Post.create(body: 'cccccc')
    MyClass.reset_filters
    MyClass.sort_on(:body, type: :scope, internal_name: :order_on_body_one_param, scope_params: [:direction])
    my_class = MyClass.new
    my_class.params = { sort: '-body' }

    assert_equal my_class.filtrate(Post.all), Post.order_on_body_one_param(:desc)
  end

  test "it respects direction with sort by scope" do
    Post.create(body: 'bbbbbb')
    Post.create(body: 'zzzzzz')
    Post.create(body: 'aaaaaa')
    Post.create(body: 'cccccc')
    MyClass.reset_filters
    MyClass.sort_on(:body, type: :scope, internal_name: :order_on_body_one_param, scope_params: [:direction])
    my_class_descending = MyClass.new
    my_class_descending.params = { sort: '-body' }
    my_class_ascending = MyClass.new
    my_class_ascending.params = { sort: 'body' }

    assert_equal my_class_descending.filtrate(Post.all), Post.order_on_body_one_param(:desc)
    assert_equal my_class_ascending.filtrate(Post.all), Post.order_on_body_one_param(:asc)
  end

  test "it sorts on scopes with multiple params" do
    Post.create(body: 'zzzzzz')
    Post.create(body: 'aaaaaa')
    Post.create(body: 'zzzzzz')
    Post.create(body: 'aaaaaa')
    Post.create(body: 'zzzzzz')
    Post.create(body: 'zzzzzz')
    Post.create(body: 'aaaaaa')
    MyClass.reset_filters
    MyClass.sort_on(:body, type: :scope, internal_name: :order_on_body_multi_param, scope_params: ['aaaaaa', :direction])
    my_class = MyClass.new
    my_class.params = { sort: '-body' }

    assert_equal my_class.filtrate(Post.all), Post.order_on_body_multi_param('aaaaaa', :desc)
  end

  test "it plays nicely with other sorts when sorting by scope" do
    Post.create(body: 'zzzzzz')
    Post.create(body: 'aaaaaa')
    Post.create(body: 'bbbbbb')
    Post.create(body: 'aaaaaa')
    Post.create(body: 'bbbbbb')
    Post.create(body: 'zzzzzz')
    Post.create(body: 'aaaaaa')
    MyClass.reset_filters
    MyClass.sort_on(:body, type: :scope, internal_name: :order_on_body_one_param, scope_params: [:direction])
    MyClass.sort_on(:id, type: :int)
    my_class = MyClass.new
    my_class.params = { sort: 'body,-id' }

    assert_equal my_class.filtrate(Post.all), Post.order_on_body_one_param(:asc).order(id: :desc)
  end
  # @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  # TODO: DOCS IT UP YO
  # @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
end
