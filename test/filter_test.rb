require "test_helper"

class FilterTest < ActiveSupport::TestCase
  test "it is initialized with the a param and a type" do
    filter = Brita::Filter.new("hi", :int, "hi", nil)

    assert_equal "hi", filter.param
    assert_equal :int, filter.type
    assert_equal "hi", filter.parameter.internal_name
  end

  test "it raises if the type is unknown" do
    assert_raise RuntimeError do
      Brita::Filter.new("hi", :foo, "hi", nil)
    end
  end

  test "it raises an exception if scope_params is not an array" do
    assert_raise ArgumentError do
      Brita::Filter.new("hi", :scope, "hi", nil, nil, {})
    end
  end

  test "it raises an exception if scope_params does not contain symbols" do
    assert_raise ArgumentError do
      Brita::Filter.new("hi", :scope, "hi", nil, nil, ["foo"])
    end
  end

  test "it knows what validation it needs when a datetime" do
    filter = Brita::Filter.new("hi", :datetime, "hi", nil)
    expected_validation = { format: { with: /\A.+(?:[^.]\.\.\.[^.]).+\z/, message: "must be a range" } }

    assert_equal expected_validation, filter.validation(nil)
  end

  test "it knows what validation it needs when an int" do
    filter = Brita::Filter.new("hi", :int, "hi", nil)
    expected_validation = { valid_int: true }

    assert_equal expected_validation, filter.validation(nil)
  end

  test "it accepts a singular int or array of ints" do
    filter = Brita::Filter.new([1, 2], :int, [1, 2], nil)
    expected_validation = { valid_int: true }

    assert_equal expected_validation, filter.validation(nil)
  end

  test "it does not accept a mixed array when the type is int" do
    filter = Brita::Filter.new([1, 2, "a"], :int, [1, 2, "a"], nil)
    expected_validation = { valid_int: true }

    assert_equal expected_validation, filter.validation(nil)
  end

  test "it does not accept an empty array for type int" do
    filter = Brita::Filter.new([], :int, [], nil)
    expected_validation = { valid_int: true }

    assert_equal expected_validation, filter.validation(nil)
  end

  test "it knows what validation it needs when a decimal" do
    filter = Brita::Filter.new("hi", :decimal, "hi", nil)
    expected_validation = { numericality: true, allow_nil: true }

    assert_equal expected_validation, filter.validation(nil)
  end

  test "it knows what validation it needs when a boolean" do
    filter = Brita::Filter.new("hi", :boolean, "hi", nil)
    expected_validation = { inclusion: { in: [true, false] }, allow_nil: true }

    assert_equal expected_validation, filter.validation(nil)
  end
end
