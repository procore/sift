module Brita
  # Value Object that wraps some handling of filter params
  class Parameter
    attr_reader :param, :type, :internal_name

    def initialize(param, type, internal_name = param)
      @param = param
      @type = type
      @internal_name = internal_name
    end

    def supports_ranges?
      ![:string, :text, :scope].include?(type)
    end

    def handler
      if type == :scope
        ScopeHandler.new(self)
      else
        WhereHandler.new(self)
      end
    end

    def parse(value)
      if parse_as_range?(value)
        range(value)
      else
        value
      end
    end

    private

    def parse_as_range?(value)
      supports_ranges? && value.to_s.include?("...")
    end

    def range(value)
      Range.new(*value.split("..."))
    end
  end
end
