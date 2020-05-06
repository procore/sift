module Sift
  # Value Object that wraps some handling of filter params
  class Parameter
    attr_reader :param, :type, :internal_name

    def initialize(param, type, internal_name = param)
      @param = param
      @type = type
      @internal_name = internal_name
    end
  end
end
