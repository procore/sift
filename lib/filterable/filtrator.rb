module Filterable
  class Filtrator
    attr_reader :collection, :params, :filters

    def initialize(collection, params, filters)
      self.collection = collection
      self.params = params
      self.filters = filters
    end

    def apply_all
      active_filters.each do |filter|
        apply(filter)
      end
    end

    def apply(filter)
      self.collection = literal(collection, filter)
    end

    private

    attr_writer :collection, :params, :filters

    def literal(collection, filter)
      return collection unless params[filter.param]

      case filter.type
      when :boolean
        collection.where(filter.column_name => parameter(filter) == '1')
      else
        collection.where(filter.column_name => parameter(filter))
      end
    end

    def parameter(filter)
      if params[filter.param].include?('...')
        Range.new(*params[filter.param].split('...'))
      else
        params[filter.param]
      end
    end

    def active_filters
      filters.select { |filter|
        params[filter.param].present?
      }
    end
  end
end
