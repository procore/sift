module Filterable
  # TypeValidator validates that the incoming param is of the specified type
  class TypeValidator
    RANGE_PATTERN = { format: { with: /\A.+(?:[^.]\.\.\.[^.]).+\z/, message: 'must be a range' } }.freeze
    DIGIT_RANGE_PATTERN = { format: { with: /\A\d+(...\d+)?\z/, message: 'must be int or range' } }.freeze
    DECIMAL_PATTERN = { numericality: true, allow_nil: true }.freeze
    BOOLEAN_PATTERN = { inclusion: { in: [true, false] }, allow_nil: true }.freeze

    def initialize(param, type)
      @param = param
      @type = type
    end

    attr_reader :param, :type

    def validate
      case type
      when :datetime, :date, :time
        RANGE_PATTERN
      when :int
        valid_int?
      when :decimal
        DECIMAL_PATTERN
      when :boolean
        BOOLEAN_PATTERN
      when :string
      when :text
      end
    end

    private

    def valid_int?
      is_int_array? || DIGIT_RANGE_PATTERN 
    end

    def is_int_array?
      param.is_a?(Array) && param.any? && param.all? { |param| param.is_a?(Integer) }
    end
  end
end
