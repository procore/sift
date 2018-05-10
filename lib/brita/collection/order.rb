module Brita
  module Collection
    class Order
      attr_reader :collection

      def initialize(collection)
        @collection = collection
        @sort_param = nil
        @sort_direction = nil
      end

      def order(clause)
        set_sort_criteria(clause)

        sort_collection
      end

      private

      def set_sort_criteria(clause)
        if clause.is_a?(Symbol)
          @sort_param = clause.to_s
        elsif clause.is_a?(String)
          @sort_param = clause.split(/[(,)]/)[1].strip
          @sort_direction = clause.split(/[(,)]/)[2].strip
        end
      end

      def sort_collection
        if @sort_param
          if @sort_direction == "desc"
            collection.sort_by { |c| c[@sort_param] }.reverse
          else
            collection.sort_by { |c| c[@sort_param] }
          end
        else
          collection
        end
      end
    end
  end
end
