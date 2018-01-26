module Brita
  class WhereHandler
    def initialize(param)
      @param = param
    end

    def call(collection, value, _params, _scope_params)
      collection.where(@param.internal_name => value)
    end
  end
end
