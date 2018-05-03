module Brita
  class ParameterFactory
    def self.parameter(param, type, internal_name)
      case type
      when :int
        IntParameter.new(param, type, internal_name)
      when :boolean
        BooleanParameter.new(param, type, internal_name)
      else
        Parameter.new(param, type, internal_name)
      end
    end
  end
end
