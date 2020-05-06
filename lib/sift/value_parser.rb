module Sift
  class ValueParser
    def initialize(value:, type: nil)
      @value = normalized_value(value, type)
      @type = type
    end

    def parse
      @_result ||=
        if parse_as_range?
          range_value
        elsif parse_as_boolean?
          boolean_value
        elsif parse_as_json?
          array_from_json
        else
          value
        end
    end

    def array_from_json
      result = JSON.parse(value)
      if result.is_a?(Array)
        result
      else
        value
      end
    rescue JSON::ParserError
      value
    end

    private

    def supports_ranges?
      ![:string, :text, :scope].include?(type)
    end

    def supports_json?
      type == :int
    end

    def supports_boolean?
      type == :boolean
    end

    attr_reader :value, :type

    def parse_as_range?(raw_value = value)
      supports_ranges? && raw_value.to_s.include?("...")
    end

    def range_value
      Range.new(*value.split("..."))
    end

    def parse_as_json?
      supports_json? && value.is_a?(String)
    end

    def parse_as_boolean?
      supports_boolean?
    end

    def boolean_value
      if Rails.version.to_i >= 5
        ActiveRecord::Type::Boolean.new.cast(value)
      else
        ActiveRecord::Type::Boolean.new.type_cast_from_user(value)
      end
    end

    def normalized_value(raw_value, type)
      if type == :datetime && parse_as_range?(raw_value)
        normalized_date_range(raw_value)
      else
        raw_value
      end
    end

    def normalized_date_range(raw_value)
      from_date_string, end_date_string = raw_value.split("...")
      return unless end_date_string

      parsed_dates = [from_date_string, end_date_string].map do |date_string|
        begin
          DateTime.parse(date_string.to_s)
        rescue StandardError
          date_string
        end
      end

      parsed_dates.join("...")
    end
  end
end
