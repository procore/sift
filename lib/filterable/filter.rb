module Filterable
  # Filter describes the way a parameter maps to a database column
  # and the type information helpful for validating input.
  class Filter
    RANGE_PATTERN = { format: { with: /\A.+\.\.\..+\z/ , message: "must be a range" } }.freeze
    DIGIT_RANGE_PATTERN = { format: { with: /\A\d+(...\d+)?\z/ , message: "must be int or range" } }.freeze
    DECIMAL_PATTERN = { numericality: true, allow_nil: true }.freeze
    BOOLEAN_PATTERN = { inclusion: { in: [true, false] }, allow_nil: true }.freeze

    attr_reader :param, :type, :column_name

    WHITELIST_TYPES = [:int,
                       :decimal,
                       :boolean,
                       :string,
                       :text,
                       :date,
                       :time,
                       :datetime,
                       :array,
                       :scope].freeze

    def initialize(param, type, column_name = param)
      raise "unknown filter type: #{type}" unless WHITELIST_TYPES.include?(type)
      self.param = param
      self.type = type
      self.column_name = column_name
    end

    def supports_ranges?
      ![:string, :text, :scope, :array].include?(type)
    end

    def validation
      case type
      when :datetime, :date, :time
        RANGE_PATTERN
      when :int
        DIGIT_RANGE_PATTERN
      when :decimal
        DECIMAL_PATTERN
      when :boolean
        BOOLEAN_PATTERN
      when :string
      when :text
      when :array
      end
    end

    private

    attr_writer :param, :type, :column_name

  end
end
