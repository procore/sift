module Brita
  class IntParameter < Parameter

    def parse(value)
      if parse_as_range?(value)
        range(value)
      else
        parse_as_value(value)
      end
    end

    private

    def parse_as_value(value)
      if value.is_a?(String)
        parse_json_string(value)
      else
        value
      end
    end

    def parse_json_string(value)
      # parse as JSON to support sending parameters as an array rather than individually
      # this will help reduce the payload size for query parameters in the URL
      JSON.parse(value)
    rescue TypeError => e
      value
    end
  end
end
