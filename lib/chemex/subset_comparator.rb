module Chemex
  class SubsetComparator
    def initialize(array)
      @array = array
    end

    def include?(other)
      @array.to_set >= other.to_set
    end
  end
end
