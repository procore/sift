module Brita
  class CollectionHandler
    def initialize(param)
      @param = param
    end

    def call(collection, value, _params, _scope_params)
      if collection.is_a?(Array)
        select_from_collection(collection, value)
      else
        collection.where(@param.internal_name => value)
      end
    end

    def select_from_collection(collection, value)
      if value.is_a?(Array)
        collection.select do |item|
          value.include?(item.with_indifferent_access[@param.internal_name])
        end
      else
        collection.select do |item|
          item.with_indifferent_access[@param.internal_name] == value
        end
      end
    end
  end
end
