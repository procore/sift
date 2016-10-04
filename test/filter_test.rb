require 'test_helper'

class FilterTest < ActiveSupport::TestCase
  test 'it is initialized with the a param and a type' do
    filter = Filterable::Filter.new('hi', :int)

    assert_equal 'hi', filter.param
    assert_equal :int, filter.type
    assert_equal 'hi', filter.internal_name
  end

  test 'it raises if the type is unknown' do
    assert_raise RuntimeError do
      Filterable::Filter.new('hi', :foo)
    end
  end

  test 'it knows what validation it needs when a datetime' do
    filter = Filterable::Filter.new('hi', :datetime)
    expected_validation = { format: { with: /\A.+\.\.\..+\z/ , message: "must be a range" } }

    assert_equal expected_validation, filter.validation
  end

  test 'it knows what validation it needs when an int' do
    filter = Filterable::Filter.new('hi', :int)
    expected_validation = { format: { with: /\A\d+(...\d+)?\z/ , message: "must be int or range" } }

    assert_equal expected_validation, filter.validation
  end

  test 'it knows what validation it needs when a decimal' do
    filter = Filterable::Filter.new('hi', :decimal)
    expected_validation = { numericality: true, allow_nil: true }

    assert_equal expected_validation, filter.validation
  end

  test 'it knows what validation it needs when a boolean' do
    filter = Filterable::Filter.new('hi', :boolean)
    expected_validation = { inclusion: { in: [true, false] }, allow_nil: true }

    assert_equal expected_validation, filter.validation
  end

  test 'stringy types do not support ranges' do
    filter = Filterable::Filter.new('hi', :string)

    assert !filter.supports_ranges?
  end
end
