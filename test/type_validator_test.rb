require 'test_helper'

class TypeValidatorTest < ActiveSupport::TestCase
  test 'it does not accept a type that is not whitelisted' do
    validator = Filterable::TypeValidator.new("test", :foo_bar)

    assert_equal false, validator.valid_type?
  end

  test 'it accepts arrays of integers for type int' do
    validator = Filterable::TypeValidator.new([1,2], :int)
    expected_validation = { :valid_int => true }

    assert_equal expected_validation, validator.validate
  end

  test 'it accepts a single integer for type int' do
    validator = Filterable::TypeValidator.new(1, :int)
    expected_validation = { :valid_int => true }

    assert_equal expected_validation, validator.validate
  end
end
