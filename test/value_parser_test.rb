require "test_helper"

class FilterTest < ActiveSupport::TestCase
  test "returns the original value without options" do
    parser = Brita::ValueParser.new(value: "hi")

    assert_equal "hi", parser.parse
  end

  test "With options an array of integers results in an array of integers" do
    options = {
      supports_ranges: true,
      supports_json: true
    }
    parser = Brita::ValueParser.new(value: [1,2,3])

    assert_equal [1,2,3], parser.parse
  end

  test "With options a json string array of integers results in an array of integers" do
    options = {
      supports_ranges: true,
      supports_json: true
    }
    parser = Brita::ValueParser.new(value: "[1,2,3]", options: options)

    assert_equal [1,2,3], parser.parse
  end

  test "with invalid json returns original value" do
    options = {
      supports_ranges: true,
      supports_json: true
    }
    parser = Brita::ValueParser.new(value: "[1,2,3", options: options)

    assert_equal "[1,2,3", parser.parse
  end

  test "JSON parsing only supports arrays" do
    options = {
      supports_json: true
    }
    json_string = "{\"a\":4}"
    parser = Brita::ValueParser.new(value: json_string, options: options)

    assert_equal json_string, parser.parse
  end

  test "With options a range string of integers results in a range" do
    options = {
      supports_ranges: true,
      supports_json: true
    }
    parser = Brita::ValueParser.new(value: "1...3", options: options)

    assert_instance_of Range, parser.parse
  end

  test "parses true from 1" do
    options = {
      supports_boolean: true
    }
    parser = Brita::ValueParser.new(value: 1, options: options)

    assert_equal true, parser.parse
  end

  test "parses false from 0" do
    options = {
      supports_boolean: true
    }
    parser = Brita::ValueParser.new(value: 0, options: options)

    assert_equal false, parser.parse
  end
end
