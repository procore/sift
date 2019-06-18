module Sift
  class ValueParser
    def initialize(value:, options: {})
      @value = value
      @supports_boolean = options.fetch(:supports_boolean, false)
      @supports_ranges = options.fetch(:supports_ranges, false)
      @supports_json = options.fetch(:supports_json, false)
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
    attr_reader :value, :supports_boolean, :supports_json, :supports_ranges

    def parse_as_range?
      supports_ranges && value.to_s.include?("...")
    end

    def range_value
      Range.new(*value.split("..."))
    end

    def parse_as_json?
      supports_json && value.is_a?(String)
    end

    def parse_as_boolean?
      supports_boolean
    end

    def boolean_value
      if Rails.version.starts_with?("5")
        ActiveRecord::Type::Boolean.new.cast(value)
      else
        ActiveRecord::Type::Boolean.new.type_cast_from_user(value)
      end
    end
  end
end
