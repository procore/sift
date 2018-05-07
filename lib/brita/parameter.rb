module Brita
  # Value Object that wraps some handling of filter params
  class Parameter
    attr_reader :param, :type, :internal_name

    def initialize(param, type, internal_name = param)
      @param = param
      @type = type
      @internal_name = internal_name
    end

    def parse_options
      {
        supports_boolean: supports_boolean?,
        supports_ranges: supports_ranges?,
        supports_json: supports_json?
      }
    end

    def handler
      if type == :scope
        ScopeHandler.new(self)
      else
        WhereHandler.new(self)
      end
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
  end
end
