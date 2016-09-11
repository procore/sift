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
