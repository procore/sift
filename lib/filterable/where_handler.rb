module Filterable
  class WhereHandler
    def initialize(param)
      @param = param
    end

    def call(collection, value, params, scope_params)
      collection.where(@param.internal_name => value)
    end
  end
end
