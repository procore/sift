module Sift
  class WhereHandler
    def initialize(raw_value, parameter)
      @param = parameter
      @value = ValueParser.new(value: raw_value, type: parameter.type).parse
    end

    def call(collection)
      collection.where(@param.internal_name => @value)
    end
  end
end
