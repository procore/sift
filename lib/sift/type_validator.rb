module Sift
  # TypeValidator validates that the incoming param is of the specified type
  class TypeValidator
    RANGE_PATTERN = { format: { with: /\A.+(?:[^.]\.\.\.[^.]).+\z/, message: "must be a range" }, valid_date_range: true }.freeze
    DECIMAL_PATTERN = { numericality: true, allow_nil: true }.freeze
    BOOLEAN_PATTERN = { inclusion: { in: [true, false] }, allow_nil: true }.freeze

    WHITELIST_TYPES = [:int,
                       :decimal,
                       :boolean,
                       :string,
                       :text,
                       :date,
                       :time,
                       :datetime,
                       :scope].freeze

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
      end
    end

    def valid_type?
      WHITELIST_TYPES.include?(type)
    end

    private

    def valid_int?
      { valid_int: true }
    end
  end
end
