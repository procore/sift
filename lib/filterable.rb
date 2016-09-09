module Filterable
  extend ActiveSupport::Concern

  def filtrate(collection)
    collection
  end

  def _filters
    self.class.filters
  end

  class_methods do


    def filter_on(parameter, type: :literal, column_name: parameter)
      filters << parameter
    end

    def _filters
      @_filters ||= []
    end
  end
end
