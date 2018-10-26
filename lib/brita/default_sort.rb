module Brita
  class DefaultSort
    attr_reader :parameter, :direction

    def initialize(parameter:, direction: :asc)
      @parameter = parameter
      @direction = direction
    end

    def sort_condition
      @_sort_condition ||= direction == :asc ? parameter.to_s : "-#{parameter}"
    end
  end
end
