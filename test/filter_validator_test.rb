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

    validator = Filterable::FilterValidator.new([filter], { hi: 'hi' })
    assert !validator.valid?
  end

  test 'it validates decimals are numerical' do
    filter = Filterable::Filter.new(:hi, :decimal, :hi)

    validator = Filterable::FilterValidator.new([filter], { hi: 2.13 })
    assert validator.valid?
  end

  test 'it validates decimals cannot be strings' do
    filter = Filterable::Filter.new(:hi, :decimal, :hi)

    validator = Filterable::FilterValidator.new([filter], { hi: '123 hi' })
    assert !validator.valid?
  end

  test 'it validate boolean are booleans' do
    filter = Filterable::Filter.new(:hi, :boolean, :hi)

    validator = Filterable::FilterValidator.new([filter], { hi: true })
    assert validator.valid?
  end

  test 'it validates booleans are not strings' do
    filter = Filterable::Filter.new(:hi, :boolean, :hi)

    validator = Filterable::FilterValidator.new([filter], { hi: 'true' })
    assert !validator.valid?
  end

  test 'it validates multiple fields' do
    bool_filter = Filterable::Filter.new(:hi, :boolean, :hi)
    dec_filter = Filterable::Filter.new(:bye, :decimal, :bye)

    validator = Filterable::FilterValidator.new([bool_filter, dec_filter], { hi: true,  bye: 1.24})
    assert validator.valid?
  end

  test 'it invalidates when one of two filters is invalid' do
    bool_filter = Filterable::Filter.new(:hi, :boolean, :hi)
    dec_filter = Filterable::Filter.new(:bye, :decimal, :bye)

    validator = Filterable::FilterValidator.new([bool_filter, dec_filter], { hi: 'blah',  bye: 1.24})
    assert !validator.valid?
  end

  test 'it invalidates when both fields are invalid' do
    bool_filter = Filterable::Filter.new(:hi, :boolean, :hi)
    dec_filter = Filterable::Filter.new(:bye, :decimal, :bye)

    validator = Filterable::FilterValidator.new([bool_filter, dec_filter], { hi: 'blah',  bye: 'blue'})
    assert !validator.valid?
  end

  test 'it ignores validations for filters that are not being used' do
    bool_filter = Filterable::Filter.new(:hi, :boolean, :hi)
    dec_filter = Filterable::Filter.new(:bye, :decimal, :bye)
    expected_messages = {}

    validator = Filterable::FilterValidator.new([bool_filter, dec_filter], { hi: true })
    assert validator.valid?

    assert_equal expected_messages, validator.errors.messages
  end
end
