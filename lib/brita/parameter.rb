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
        CollectionHandler.new(self)
      end
    end
  end
end
