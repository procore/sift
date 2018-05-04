module Brita
  class CollectionHandler
    def initialize(param)
      @param = param
    end

    def call(collection, value, _params, _scope_params)
      if collection.is_a?(Array)
        collection.select do |item|
          item.with_indifferent_access[@param.internal_name] == value
        end
      else
        collection.where(@param.internal_name => value)
      end
    end
  end
end
