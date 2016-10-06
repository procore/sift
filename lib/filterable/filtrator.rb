module Filterable
  # Filtrator takes a collection, params and a set of filters
  # and applies them to create a new active record collection
  # with those filters applied.
  class Filtrator
    attr_reader :collection, :params, :filters

    def self.filter(collection, filter_params, filters)
      new(collection, filter_params, filters).filter
    end

    def initialize(collection, params, filters = [])
      # TODO: rename collection, or alteast don't use it twice
      self.collection = collection
      self.params = params
      self.filters = filters
    end

    def filter
      active_filters.reduce(collection) do |col, filter|
        apply(col, filter)
      end
    end

    private

    attr_writer :collection, :params, :filters

    def apply(collection, filter)
      if filter.type == :scope
        if params[filter.param].present?
          collection.public_send(filter.column_name, parameter(filter))
        else
          filter.default.call(collection)
        end
      else
        collection.where(filter.column_name => parameter(filter))
      end
    end

    def parameter(filter)
      if filter.supports_ranges? && params[filter.param].to_s.include?('...')
        Range.new(*params[filter.param].to_s.split('...'))
      elsif filter.type == :boolean
        if Rails.version.starts_with?('5')
          ActiveRecord::Type::Boolean.new.cast(params[filter.param])
        else
          ActiveRecord::Type::Boolean.new.type_cast_from_user(params[filter.param])
        end
      else
        params[filter.param]
      end
    end

    def active_filters
      filters.select { |filter|
        params[filter.param].present? || filter.default
      }
    end
  end
end
