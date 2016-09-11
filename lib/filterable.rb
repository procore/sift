require 'filterable/filter'
require 'filterable/filter_validator'

module Filterable
  extend ActiveSupport::Concern

  class Filtrator < Struct.new(:collection, :params, :filters)
    def apply_all
      active_filters.each do |filter|
        apply(filter)
      end
    end

    def apply(filter)
      self.collection = literal(collection, filter)
    end

    private

    def literal(collection, filter)
      if params[filter.param]
        collection.where(filter.column_name => params[filter.param])
      else
        collection
      end
    end

    def active_filters
      filters.select { |filter|
        params[filter.param].present?
      }
    end
  end

  def filtrate(collection)
    filter_collection = Filtrator.new(collection, filter_params, self.class.filters)
    filter_collection.apply_all
    filter_collection.collection
  end

  def filter_params
    params.fetch(:filters, {})
  end

  def filters_valid?
    FilterValidator.new(self.class.filters, params).valid?
  end

  def filter_errors
    x = FilterValidator.new(self.class.filters, params)
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
