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
      values = get_parsed_values(value)
      internal_name = @param.internal_name

      collection.select do |item|
        values.include?(item.with_indifferent_access[internal_name])
      end
    end

    def check_for_integer(value)
      Integer(value) rescue value
    end

    def get_parsed_values(value)
      Array.wrap(value).map { |v| v.is_a?(String) ? check_for_integer(v) : v }
    end
  end
end
