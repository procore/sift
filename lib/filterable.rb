require 'filterable/filter'
require 'filterable/filter_validator'
require 'filterable/filtrator'
require 'filterable/sort'

module Filterable
  extend ActiveSupport::Concern

  def filtrate(collection)
    Filtrator.filter(collection, filter_params, filters).order(order_hash)
  end

  def filter_params
    params.fetch(:filters, {})
  end

  def filters_valid?
    filter_validator.valid?
  end

  def filter_errors
    filter_validator.errors.messages
  end

  private

  def filter_validator
    @_filter_validator ||= FilterValidator.new(filters, filter_params)
  end

  def order_hash
    params.fetch(:sort, '').split(',').reduce({}) { |order_hash, raw_field|
      sort_field = raw_field.gsub(/\W/,'')
      sortable_params = sorts.map(&:param)
      if sortable_params.include?(sort_field)
        order_hash[sort_field] = raw_field.match('-') ? :desc : :asc
      end
      order_hash
    }
  end

  def sorts
    self.class.sorts
  end

  def filters
    self.class.filters
  end

  class_methods do
    def filter_on(parameter, type:, internal_name: parameter)
      filters << Filter.new(parameter, type, internal_name)
    end

    def filters
      @_filters ||= []
    end

    # TODO: this is only used in tests, can I kill it?
    def reset_filters
      @_filters = []
    end

    def sort_on(parameter, type:, internal_name: parameter)
      sorts << Sort.new(parameter, type, internal_name)
    end

    def sorts
      @_sorts ||= []
    end

    def reset_sorts
      @_sorts = []
    end
  end
end
