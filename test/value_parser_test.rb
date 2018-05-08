require "test_helper"

class FilterTest < ActiveSupport::TestCase
  test "returns the original value without options" do
    parser = Brita::ValueParser.new(value: "hi")

    assert_equal "hi", parser.parse
  end

  test "With options an array of integers results in an array of integers" do
    parser = Brita::ValueParser.new(value: [1, 2, 3])

    assert_equal [1, 2, 3], parser.parse
  end

  test "With options a json string array of integers results in an array of integers" do
    options = {
      supports_ranges: true,
      supports_json: true
    }
    parser = Brita::ValueParser.new(value: "[1,2,3]", options: options)

    assert_equal [1, 2, 3], parser.parse
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

  test "parses range for time string range" do
    options = {
      supports_ranges: true
    }
    start_time = Time.new(2008, 6, 21, 13, 30, 0, "+09:00")
    end_time = Time.new(2008, 6, 21, 13, 45, 0, "+09:00")
    range_string = "#{start_time}...#{end_time}"
    parser = Brita::ValueParser.new(value: range_string, options: options)

    result = parser.parse
    assert_instance_of Range, result
    assert_equal result.max, end_time.to_s
  end

  test "parses range for Date string range" do
    options = {
      supports_ranges: true
    }
    start_date = Date.new(2018, 01, 26)
    end_date = Time.new(2018, 01, 29)
    range_string = "#{start_date}...#{end_date}"
    parser = Brita::ValueParser.new(value: range_string, options: options)

    result = parser.parse
    assert_instance_of Range, result
    assert_equal result.max, end_date.to_s
  end
end
