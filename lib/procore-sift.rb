require "sift/filter"
require "sift/filter_validator"
require "sift/filtrator"
require "sift/sort"
require "sift/subset_comparator"
require "sift/type_validator"
require "sift/parameter"
require "sift/value_parser"
require "sift/scope_handler"
require "sift/where_handler"
require "sift/validators/valid_int_validator"
require "sift/validators/valid_date_range_validator"
require "brita/default_sort"

module Sift
  extend ActiveSupport::Concern

  def filtrate(collection)
    Filtrator.filter(collection, params, filters)
  end

  def filter_params
    params.fetch(:filters, {})
  end

  def sort_params
    apply_default_sort_params
    params.fetch(:sort, "").split(",") if filters.any? { |filter| filter.is_a?(Sort) }
  end

  def filters_valid?
    filter_validator.valid?
  end

  def filter_errors
    filter_validator.errors.messages
  end

  private

  def filter_validator
    @_filter_validator ||= FilterValidator.build(
      filters: filters,
      sort_fields: self.class.sort_fields,
      filter_params: filter_params,
      sort_params: sort_params,
    )
  end

  def filters
    self.class.filters
  end

  def default_sorts
    self.class.default_sorts
  end

  def sorts_exist?
    filters.any? { |filter| filter.is_a?(Sort) }
  end

  def apply_default_sort_params
    return unless default_sorts && params[:sort].blank?
    params[:sort] = default_sorts.map { |default_sort| default_sort.sort_condition }.join(',')
  end

  class_methods do
    def filter_on(parameter, type:, internal_name: parameter, default: nil, validate: nil, scope_params: [])
      filters << Filter.new(parameter, type, internal_name, default, validate, scope_params)
    end

    def filters
      @_filters ||= []
    end

    # TODO: this is only used in tests, can I kill it?
    def reset_filters
      @_filters = []
      @_default_sorts = []
    end

    def sort_fields
      @_sort_fields ||= []
    end

    def default_sorts
      @_default_sorts ||= []
    end

    def sort_on(parameter, type:, internal_name: parameter, scope_params: [])
      filters << Sort.new(parameter, type, internal_name, scope_params)
      sort_fields << parameter.to_s
      sort_fields << "-#{parameter}"
    end

    def default_sort(parameter, direction: :asc)
      default_sorts << DefaultSort.new(
        parameter: parameter,
        direction: direction
      )
    end
  end
end
