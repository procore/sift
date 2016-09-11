require 'filterable/filter'
require 'filterable/filter_validator'
require 'filterable/filtrator'

module Filterable
  extend ActiveSupport::Concern


  def filtrate(collection)
    filter_collection = Filtrator.new(collection, filter_params, self.class.filters)
    filter_collection.apply_all
    filter_collection.collection
  end

  def filter_params
    params.fetch(:filters, {})
  end

  def filters_valid?
    FilterValidator.new(self.class.filters, filter_params).valid?
  end

  def filter_errors
    x = FilterValidator.new(self.class.filters, filter_params)
    x.valid?
    x.errors.messages
  end

  class_methods do
    def filter_on(parameter, type:, column_name: parameter)
      filters << Filter.new(parameter, type, column_name)
    end

    def filters
      @_filters ||= []
    end

    def allowed_parameters
      filters.map(&:param)
    end

    # TODO: this is only used in tests, can I kill it?
    def reset_filters
      @_filters = []
    end
  end
end
