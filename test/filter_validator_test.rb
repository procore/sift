require "test_helper"

class FilterValidatorTest < ActiveSupport::TestCase
  test "it validates that integers are string integers" do
    filter = Filterable::Filter.new(:hi, :int, :hi, nil)
    validator = Filterable::FilterValidator.new(
      [filter],
      { filters: { hi: "1" } },
      [],
      filter_params: { hi: "1" },
      sort_params: "",
    )

    assert validator.valid?
    assert_equal Hash.new, validator.errors.messages
  end

  test "it validates that integers are numeric integers" do
    filter = Filterable::Filter.new(:hola, :int, :hola, nil)
    validator = Filterable::FilterValidator.new(
      [filter],
      { filters: { hola: 2 } },
      [],
      filter_params: { hola: 2 },
      sort_params: "",
    )

    assert validator.valid?
    assert_equal Hash.new, validator.errors.messages
  end

  test "it validates integers cannot be strings" do
    filter = Filterable::Filter.new(:hi, :int, :hi, nil)
    expected_messages = { hi: ["must be integer, array of integers, or range"] }

    validator = Filterable::FilterValidator.new(
      [filter],
      { filters: { hi: "hi123" } },
      [],
      filter_params: { hi: "hi123" },
      sort_params: "",
    )
    assert !validator.valid?
    assert_equal expected_messages, validator.errors.messages
  end

  test "it validates decimals are numerical" do
    filter = Filterable::Filter.new(:hi, :decimal, :hi, nil)

    validator = Filterable::FilterValidator.new(
      [filter],
      { filters: { hi: 2.13 } },
      [],
      filter_params: { hi: 2.13 },
      sort_params: "",
    )
    assert validator.valid?
    assert_equal Hash.new, validator.errors.messages
  end

  test "it validates decimals cannot be strings" do
    filter = Filterable::Filter.new(:hi, :decimal, :hi, nil)
    expected_messages = { hi: ["is not a number"] }

    validator = Filterable::FilterValidator.new(
      [filter],
      { filters: { hi: "123 hi" } },
      [],
      filter_params: { hi: "123 hi" },
      sort_params: "",
    )
    assert !validator.valid?
    assert_equal expected_messages, validator.errors.messages
  end

  test "it validates booleans are 0 or 1" do
    filter = Filterable::Filter.new(:hi, :boolean, :hi, nil)

    validator = Filterable::FilterValidator.new(
      [filter],
      { filters: { hi: false } },
      [],
      filter_params: { hi: false },
      sort_params: "",
    )
    assert validator.valid?
    assert_equal Hash.new, validator.errors.messages
  end

  test "it validates multiple fields" do
    bool_filter = Filterable::Filter.new(:hi, :boolean, :hi, nil)
    dec_filter = Filterable::Filter.new(:bye, :decimal, :bye, nil)

    validator = Filterable::FilterValidator.new(
      [bool_filter, dec_filter],
      { filters: { hi: true, bye: 1.24 } },
      [],
      filter_params: { hi: true, bye: 1.24 },
      sort_params: "",
    )
    assert validator.valid?
    assert_equal Hash.new, validator.errors.messages
  end

  test "it invalidates when one of two filters is invalid" do
    bool_filter = Filterable::Filter.new(:hi, :boolean, :hi, nil)
    dec_filter = Filterable::Filter.new(:bye, :decimal, :bye, nil)
    expected_messages = { bye: ["is not a number"] }

    validator = Filterable::FilterValidator.new(
      [bool_filter, dec_filter],
      { filters: { hi: "hi", bye: "whatup" } },
      [],
      filter_params: { hi: "hi", bye: "whatup" },
      sort_params: "",
    )
    assert !validator.valid?
    assert_equal expected_messages, validator.errors.messages
  end

  test "it invalidates when both fields are invalid" do
    bool_filter = Filterable::Filter.new(:hi, :date, :hi, nil)
    dec_filter = Filterable::Filter.new(:bye, :decimal, :bye, nil)
    expected_messages = { hi: ["must be a range"], bye: ["is not a number"] }

    validator = Filterable::FilterValidator.new(
      [bool_filter, dec_filter],
      { filters: { hi: 1, bye: "blue" } },
      [],
      filter_params: { hi: 1, bye: "blue" },
      sort_params: "",
    )
    assert !validator.valid?
    assert_equal expected_messages, validator.errors.messages
  end

  test "it ignores validations for filters that are not being used" do
    bool_filter = Filterable::Filter.new(:hi, :boolean, :hi, nil)
    dec_filter = Filterable::Filter.new(:bye, :decimal, :bye, nil)

    validator = Filterable::FilterValidator.new(
      [bool_filter, dec_filter],
      { filters: { hi: true } },
      [],
      filter_params: { hi: true },
      sort_params: "",
    )
    assert validator.valid?
    assert_equal Hash.new, validator.errors.messages
  end

  test "it allows ranges" do
    filter = Filterable::Filter.new(:hi, :int, :hi, nil)

    validator = Filterable::FilterValidator.new(
      [filter],
      { filters: { hi: "1..10" } },
      [],
      filter_params: { hi: "1..10" },
      sort_params: "",
    )
    assert validator.valid?
    assert_equal Hash.new, validator.errors.messages
  end

  test "datetimes are invalid unless they are a range" do
    filter = Filterable::Filter.new(:hi, :datetime, :hi, nil)

    validator = Filterable::FilterValidator.new(
      [filter],
      { filters: { hi: "2016-09-11T22:42:47Z...2016-09-11T22:42:47Z" } },
      [],
      filter_params: { hi: "2016-09-11T22:42:47Z...2016-09-11T22:42:47Z" },
      sort_params: "",
    )
    assert validator.valid?
    assert_equal Hash.new, validator.errors.messages
  end

  test "datetimes are invalid when not a range" do
    filter = Filterable::Filter.new(:hi, :datetime, :hi, nil)
    expected_messages = { hi: ["must be a range"] }

    validator = Filterable::FilterValidator.new(
      [filter],
      { filters: { hi: "2016-09-11T22:42:47Z" } },
      [],
      filter_params: { hi: "2016-09-11T22:42:47Z" },
      sort_params: "",
    )
    assert !validator.valid?
    assert_equal expected_messages, validator.errors.messages
  end

  test "it validates that sort exists" do
    filter = Filterable::Sort.new(:hi, :datetime, :hi)
    expected_messages = { sort: ["is not included in the list"] }

    validator = Filterable::FilterValidator.new(
      [filter],
      { sort: "-hi" },
      [],
      filter_params: {},
      sort_params: "-hi",
    )
    assert !validator.valid?
    assert_equal expected_messages, validator.errors.messages
  end

  test "it respects a custom validation" do
    error_message = "super duper error message"
    filter = Filterable::Filter.new(:hi, :int, :hi, nil, ->(validator) {
      validator.errors.add(:base, error_message)
    })
    expected_messages = { base: [error_message] }

    validator = Filterable::FilterValidator.new(
      [filter],
      { filters: { hi: 1 } },
      [],
      filter_params: { hi: 1 },
      sort_params: "",
    )
    assert !validator.valid?
    assert_equal expected_messages, validator.errors.messages
  end

  test "custom validation supercedes type validation" do
    filter = Filterable::Filter.new(:hi, :int, :hi, nil, ->(validator) {})

    validator = Filterable::FilterValidator.new(
      [filter],
      { filters: { hi: "zebra" } },
      [],
      filter_params: { hi: "zebra" },
      sort_params: "",
    )
    assert validator.valid?
    assert_equal Hash.new, validator.errors.messages
  end
end
