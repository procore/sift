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
        collection = if val.is_a?(Array)
          if val.include?(nil)
            condition = val.each_with_index.map do |element, i|
              "#{@param.internal_name}->>'#{key}' #{element === nil ? 'IS NULL' : "= :value_#{i}"}"
            end.join(' OR ')
            elements = Hash[val.each_with_index.map { |item, i| ["value_#{i}".to_sym, item.to_s] } ]
          else
            condition =  "('{' || TRANSLATE(#{@param.internal_name}->>'#{key}', '[]','') || '}')::text[] && ARRAY[?]"
            elements = val.map(&:to_s)
          end
          collection.where(condition, elements)
        else
          collection.where("#{@param.internal_name}->>'#{key}' = ?", val.to_s)
        end
      end
      collection
    end
  end
end
