class ValidIntValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, (options[:message] || "must be int or range") unless
      valid_int?(value)
  end

  private

  def valid_int?(value)
    is_integer_array?(value) || is_integer_or_range?(value)
  end

  def is_integer_array?(value)
    value.is_a?(Array) && value.any? && value.all? { |value| value.is_a?(Integer) }
  end

  def is_integer_or_range?(value)
    value.is_a?(Integer) || !!(/\A\d+(...\d+)?\z/ =~ value)
  end
end