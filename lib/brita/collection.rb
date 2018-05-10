module Brita
  class Collection
    attr_reader :collection

    def initialize(collection)
      @collection = collection
      @filter_param = nil
      @filter_values = nil
    end

    # def type
    #   collection.is_a?(Array) ? :array : :other
    # end

    def where(clause)
      set_filter_criteria(clause)

      select_from_collection
    end

    def order(clause)
      @collection
    end

    private

    def set_filter_criteria(clause)
      if clause.length == 1
        clause.each do |k, v|
          @filter_param = k
          @filter_values = get_parsed_values(v)
        end
      else
        raise(StandardError)
      end
    end

    def select_from_collection
      @collection.select do |item|
        @filter_values.include?(item.with_indifferent_access[@filter_param])
      end
    end

    def get_parsed_values(values)
      Array.wrap(values).map { |v| cast(v) }
    end

    def cast(value)
      if value.is_a?(String)
        cast_to_int(value)
      else
        value
      end
    end

    def cast_to_int(value)
      Integer(value) rescue value
    end

    def check_for_float(value)
      Float(value) rescue value
    end
  end
end
