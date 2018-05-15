module Brita
  module Collection
    class Where
      attr_reader :collection

      def initialize(collection)
        @collection = collection
        @filter_param = nil
        @filter_values = nil
      end

      def where(clause)
        set_filter_criteria(clause)

        select_from_collection
      end

      private

      def set_filter_criteria(clause)
        clause.each do |k, v|
          @filter_param = k
          @filter_values = get_parsed_values(v)
        end
      end

      def select_from_collection
        collection.select do |item|
          @filter_values.include?(item.with_indifferent_access[@filter_param])
        end
      end

      def get_parsed_values(values)
        Array.wrap(values).map { |v| cast(v) }
      end

      def cast(value)
        new_val = value

        if value.is_a?(String)
          new_val = cast_to_int(value)

          if new_val.is_a?(String)
            new_val = cast_to_float(new_val)
          end
        end

        new_val
      end

      def cast_to_int(value)
        Integer(value) rescue value
      end

      def cast_to_float(value)
        Float(value) rescue value
      end
    end
  end
end
