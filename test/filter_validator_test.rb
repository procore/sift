require 'test_helper'

class FilterValidatorTest < ActiveSupport::TestCase
  test 'it validates that integers are numeric integers' do
    filter = Filterable::Filter.new(:hi, :int, :hi)

    validator = Filterable::FilterValidator.new([filter], { hi: 1 })
    assert validator.valid?
    assert_equal Hash.new, validator.errors.messages
  end

  test 'it validates integers cannot be strings' do
    filter = Filterable::Filter.new(:hi, :int, :hi)
    expected_messages = { hi: ["must be int or range"] }

    validator = Filterable::FilterValidator.new([filter], { hi: 'hi123' })
    assert !validator.valid?
    assert_equal expected_messages, validator.errors.messages
  end

  test 'it validates decimals are numerical' do
    filter = Filterable::Filter.new(:hi, :decimal, :hi)

    validator = Filterable::FilterValidator.new([filter], { hi: 2.13 })
    assert validator.valid?
    assert_equal Hash.new, validator.errors.messages
  end

  test 'it validates decimals cannot be strings' do
    filter = Filterable::Filter.new(:hi, :decimal, :hi)
    expected_messages = { hi: ["is not a number"] }


    validator = Filterable::FilterValidator.new([filter], { hi: '123 hi' })
    assert !validator.valid?
    assert_equal expected_messages, validator.errors.messages
  end

  test 'it validates booleans are 0 or 1' do
    filter = Filterable::Filter.new(:hi, :boolean, :hi)

    validator = Filterable::FilterValidator.new([filter], { hi: false })
    assert validator.valid?
    assert_equal Hash.new, validator.errors.messages
  end

  test 'it validates multiple fields' do
    bool_filter = Filterable::Filter.new(:hi, :boolean, :hi)
    dec_filter = Filterable::Filter.new(:bye, :decimal, :bye)

    validator = Filterable::FilterValidator.new([bool_filter, dec_filter], { hi: true,  bye: 1.24})
    assert validator.valid?
    assert_equal Hash.new, validator.errors.messages
  end

  test 'it invalidates when one of two filters is invalid' do
    bool_filter = Filterable::Filter.new(:hi, :boolean, :hi)
    dec_filter = Filterable::Filter.new(:bye, :decimal, :bye)
    expected_messages = { bye: ["is not a number"] }

    validator = Filterable::FilterValidator.new([bool_filter, dec_filter], { hi: 'hi',  bye: 'whatup' })
    assert !validator.valid?
    assert_equal expected_messages, validator.errors.messages
  end

  test 'it invalidates when both fields are invalid' do
    bool_filter = Filterable::Filter.new(:hi, :date, :hi)
    dec_filter = Filterable::Filter.new(:bye, :decimal, :bye)
    expected_messages = { hi: ["must be a range"], bye: ["is not a number"] }

    validator = Filterable::FilterValidator.new([bool_filter, dec_filter], { hi: 1,  bye: 'blue'})
    assert !validator.valid?
    assert_equal expected_messages, validator.errors.messages
  end

  test 'it ignores validations for filters that are not being used' do
    bool_filter = Filterable::Filter.new(:hi, :boolean, :hi)
    dec_filter = Filterable::Filter.new(:bye, :decimal, :bye)

    validator = Filterable::FilterValidator.new([bool_filter, dec_filter], { hi: true })
    assert validator.valid?
    assert_equal Hash.new, validator.errors.messages
  end

  test 'it allows ranges' do
    filter = Filterable::Filter.new(:hi, :int, :hi)

    validator = Filterable::FilterValidator.new([filter], { hi: "1..10" })
    assert validator.valid?
    assert_equal Hash.new, validator.errors.messages
  end

  test 'datetimes are invalid unless they are a range' do
    filter = Filterable::Filter.new(:hi, :datetime, :hi)

    validator = Filterable::FilterValidator.new([filter], { hi: "2016-09-11T22:42:47Z...2016-09-11T22:42:47Z" })
    assert validator.valid?
    assert_equal Hash.new, validator.errors.messages
  end

  test "datetimes are invalid when not a range" do
    filter = Filterable::Filter.new(:hi, :datetime, :hi)
    expected_messages = { hi: ["must be a range"] }

    validator = Filterable::FilterValidator.new([filter], { hi: "2016-09-11T22:42:47Z" })
    assert !validator.valid?
    assert_equal expected_messages, validator.errors.messages
  end
end
