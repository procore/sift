require 'filterable/filter'
require 'filterable/filter_validator'
require 'filterable/filtrator'

module Filterable
  extend ActiveSupport::Concern


  def filtrate(collection)
    Filtrator.filter(collection, filter_params, filters)
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

  def filters
    self.class.filters
  end

  class_methods do
    def filter_on(parameter, type:, column_name: parameter)
      filters << Filter.new(parameter, type, column_name)
    end

    def filters
      @_filters ||= []
    end

    # TODO: this is only used in tests, can I kill it?
    def reset_filters
      @_filters = []
    end
  end
end
