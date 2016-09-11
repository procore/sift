module Filterable
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
      if WHITELIST_TYPES.include?(type)
        super(param, type, column_name)
      else
        raise "unknown filter type: #{type}"
      end
    end

    def validation
      case type
      when :int
        { numericality: { only_integer: true } }
      when :decimal
        { numericality: true }
      when :boolean
        { inclusion: { in: [true, false] } }
      when :string
      when :text
      when :date
      when :time
      when :datetime
      end
    end
  end
end
