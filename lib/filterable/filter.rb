module Filterable
  # Filter describes the way a parameter maps to a database column
  # and the type information helpful for validating input.
  class Filter
    RANGE_PATTERN = { format: { with: /\A.+(?:[^.]\.\.\.[^.]).+\z/ , message: "must be a range" } }.freeze
    DIGIT_RANGE_PATTERN = { format: { with: /\A\d+(...\d+)?\z/ , message: "must be int or range" } }.freeze
    DECIMAL_PATTERN = { numericality: true, allow_nil: true }.freeze
    BOOLEAN_PATTERN = { inclusion: { in: [true, false] }, allow_nil: true }.freeze


    attr_reader :param, :type, :internal_name, :default, :custom_validate

    WHITELIST_TYPES = [:int,
                       :decimal,
                       :boolean,
                       :string,
                       :text,
                       :date,
                       :time,
                       :datetime,
                       :scope].freeze

    def initialize(param, type, internal_name, default, custom_validate = nil)
      raise "unknown filter type: #{type}" unless WHITELIST_TYPES.include?(type)
      @param = param
      @type = type
      @internal_name = internal_name || @param
      @default = default
      @custom_validate = custom_validate
    end

    def supports_ranges?
      ![:string, :text, :scope].include?(type)
    end

    def validation(_)
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
      end
    end

    def apply!(collection, value:, active_sorts_hash:, params: {})
      if type == :scope
        if value.present?
          begin
            collection.public_send(internal_name, parameter(value))
          rescue ArgumentError
            collection.public_send(internal_name)
          end
        elsif default.present?
          default.call(collection)
        else
          collection
        end
      else
        collection.where(internal_name => parameter(value))
      end
    end

    def always_active?
      false
    end

    def validation_field
      param
    end

    private

    def parameter(value)
      if supports_ranges? && value.to_s.include?('...')
        Range.new(*value.split('...'))
      elsif type == :boolean
        if Rails.version.starts_with?('5')
          ActiveRecord::Type::Boolean.new.cast(value)
        else
          ActiveRecord::Type::Boolean.new.type_cast_from_user(value)
        end
      else
        value
      end
    end
  end
end
