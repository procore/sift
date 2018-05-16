module Brita
  module Collection
    class ArrayWrapper
      attr_reader :attributes

      def initialize(attributes)
        @attributes = attributes
      end

      def where(clause)
        ArrayFilter.new(attributes).where(clause)
      end

      def order(clause)
        ArraySort.new(attributes).order(clause)
      end
    end
  end
end
