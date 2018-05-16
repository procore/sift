module Brita
  module Collection
    class ArraySort
      attr_reader :collection

      def initialize(collection)
        @collection = collection
      end

      def order(clause)
        sort_collection
      end

      private

      # this is a stub method
      # array sort has not been implemented yet
      def sort_collection
        collection
      end
    end
  end
end
