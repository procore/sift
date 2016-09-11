module Filterable
  # Filter describes the way a parameter maps to a database column
  # and the type information helpful for validating input.
  class Filter < Struct.new(:param, :type, :column_name)
    WHITELIST_TYPES = [:int,
                       :decimal,
                       :boolean,
                       :string,
                       :text,
                       :date,
                       :time,
                       :datetime].freeze

    def initialize(param, type, column_name)
      raise "unknown filter type: #{type}" unless WHITELIST_TYPES.include?(type)
      super(param, type, column_name)
    end

    def validation
      case type
      when :int
        { numericality: { only_integer: true }, allow_nil: true }
      when :decimal
        { numericality: true, allow_nil: true }
      when :boolean
        { inclusion: { in: [true, false] }, allow_nil: true }
      when :string
      when :text
      when :date
      when :time
      when :datetime
      end
    end
  end
end
