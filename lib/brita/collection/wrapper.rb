module Brita
  module Collection
    class Wrapper
      attr_reader :attributes

      def initialize(attributes)
        @attributes = attributes
      end

      def where(clause)
        Where.new(attributes).where(clause)
      end

      def order(clause)
        Order.new(attributes).order(clause)
      end
    end
  end
end
