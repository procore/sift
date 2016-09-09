require 'test_helper'

class Filterable::Test < ActiveSupport::TestCase
  class MyClass
    include Filterable
  end

  test "filterable exists" do
    assert_kind_of Module, Filterable
  end

  test "does nothing if no filters are registered" do
    assert_equal [], MyClass.new.filtrate([])
  end

  test "it registers filters with filter_on" do
    MyClass.filter_on(:id)

    assert_equal [:id], MyClass.filters
  end
end
