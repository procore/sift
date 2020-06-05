module Sift
  class WhereHandler
    def initialize(param)
      @param = param
    end

    def call(collection, value, _params, _scope_params)
      if @param.type == :jsonb
        apply_jsonb_conditions(collection, value)
      else
        collection.where(@param.internal_name => value)
      end
    end

    private

    def apply_jsonb_conditions(collection, value)
      return collection.where("#{@param.internal_name} @> ?", val.to_s) if value.is_a?(Array)

      value.each do |key, val|
        condition = if val.is_a?(Array)
          "('{' || TRANSLATE(#{@param.internal_name}->>'#{key}', '[]','') || '}')::int[] && ARRAY[?]"
        else # Single Value
          val = val.to_s
          "#{@param.internal_name}->>'#{key}' = ?"
        end
        collection = collection.where(condition, val)
      end
      collection
    end
  end
end
