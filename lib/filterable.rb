require 'filterable/filter'
require 'filterable/filter_validator'
require 'filterable/filtrator'
require 'filterable/sort'
require 'filterable/subset_comparator'

module Filterable
  extend ActiveSupport::Concern

  def filtrate(collection)
    Filtrator.filter(collection, filter_params, filters, sort_params)
  end

  def filter_params
    params.fetch(:filters, {})
  end

  def sort_params
    params.fetch(:sort, '').split(',') if sorts_exist?
  end

  def filters_valid?
    filter_validator.valid?
  end

  def filter_errors
    filter_validator.errors.messages
  end

  private

  def filter_validator
    @_filter_validator ||= FilterValidator.new(filters, params, self.class.sort_fields, filter_params: filter_params, sort_params: sort_params)
  end

  def filters
    self.class.filters
  end

  def sorts_exist?
    filters.any? { |filter| filter.is_a?(Sort) }
  end

  class_methods do
    def filter_on(parameter, type:, internal_name: parameter, default: nil, validate: nil)
      filters << Filter.new(parameter, type, internal_name, default, validate)
    end

    def filters
      @_filters ||= []
    end

    # TODO: this is only used in tests, can I kill it?
    def reset_filters
      @_filters = []
    end

    def sort_fields
      @_sort_fields ||= []
    end

    def sort_on(parameter, type:, internal_name: parameter)
      filters << Sort.new(parameter, type, internal_name)
      sort_fields << parameter.to_s
      sort_fields << "-#{parameter}"
    end
  end
end
