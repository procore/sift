require "test_helper"

class FilterTest < ActiveSupport::TestCase
  test "it is initialized with the a param and a type" do
    filter = Sift::Filter::Where.new("hi", :int, "hi", nil)

    assert_equal "hi", filter.param
    assert_equal :int, filter.type
    assert_equal "hi", filter.parameter.internal_name
  end

  test "it raises if the type is unknown" do
    assert_raise RuntimeError do
      Sift::Filter::Where.new("hi", :foo, "hi", nil)
    end
  end

  test "it raises an exception if scope_params is not an array" do
    assert_raise ArgumentError do
      Sift::Filter::Scope.new("hi", :scope, "hi", nil, nil, {})
    end
  end

  test "it raises an exception if scope_params does not contain symbols" do
    assert_raise ArgumentError do
      Sift::Filter::Scope.new("hi", :scope, "hi", nil, nil, ["foo"])
    end
  end

  test "it raises an exception if type scope has invalid scope types" do
    assert_raise ArgumentError do
      Sift::Filter::Scope.new("hi", :scope, "hi", nil, nil, [:foo], [:int, :foo])
    end
  end

  test "it knows what validation it needs when a datetime" do
    filter = Sift::Filter::Where.new("hi", :datetime, "hi", nil)
    expected_validation = { format: { with: /\A.+(?:[^.]\.\.\.[^.]).+\z/, message: "must be a range" }, valid_date_range: true }

    assert_equal expected_validation, filter.validation(nil)
  end

  test "it knows what validation it needs when an int" do
    filter = Sift::Filter::Where.new("hi", :int, "hi", nil)
    expected_validation = { valid_int: true }

    assert_equal expected_validation, filter.validation(nil)
  end

  test "it accepts a singular int or array of ints" do
    filter = Sift::Filter::Where.new([1, 2], :int, [1, 2], nil)
    expected_validation = { valid_int: true }

    assert_equal expected_validation, filter.validation(nil)
  end

  test "it does not accept a mixed array when the type is int" do
    filter = Sift::Filter::Where.new([1, 2, "a"], :int, [1, 2, "a"], nil)
    expected_validation = { valid_int: true }

    assert_equal expected_validation, filter.validation(nil)
  end

  test "it does not accept an empty array for type int" do
    filter = Sift::Filter::Where.new([], :int, [], nil)
    expected_validation = { valid_int: true }

    assert_equal expected_validation, filter.validation(nil)
  end

  test "it knows what validation it needs when a decimal" do
    filter = Sift::Filter::Where.new("hi", :decimal, "hi", nil)
    expected_validation = { numericality: true, allow_nil: true }

    assert_equal expected_validation, filter.validation(nil)
  end

  test "it knows what validation it needs when a boolean" do
    filter = Sift::Filter::Where.new("hi", :boolean, "hi", nil)
    expected_validation = { inclusion: { in: [true, false] }, allow_nil: true }

    assert_equal expected_validation, filter.validation(nil)
  end
end
