module Filterable
  # Filtrator takes a collection, params and a set of filters
  # and applies them to create a new active record collection
  # with those filters applied.
  class Filtrator
    attr_reader :collection, :params, :filters, :sort

    def self.filter(collection, filter_params, filters, sort = [])
      new(collection, filter_params, sort, filters).filter
    end

    def initialize(collection, params, sort, filters = [])
      @collection = collection
      @params = params
      @filters = filters
      @sort = sort
    end

    def filter
      active_filters.reduce(collection) do |col, filter|
        apply(col, filter)
      end
    end

    private

    def apply(collection, filter)
      if filter.type == :scope && filter.is_a?(Filterable::Filter)
        apply_filter_on_scope(collection, filter)
      else
        filter.apply!(collection, value: params[filter.param], active_sorts_hash: active_sorts_hash)
      end
    end

    # Method that is called with a Filterable::Filter of type :scope
    def apply_filter_on_scope(collection, filter)
      if params[filter.param].present?
        collection.public_send(filter.internal_name, parameter(filter))
      elsif filter.default.present?
        filter.default.call(collection)
      else
        collection
      end
    end

    def active_sorts_hash
      active_sorts_hash = {}
      self.sort.each do |s|
        if s.starts_with?('-')
          active_sorts_hash[s[1..-1].to_sym] = :desc
        else
          active_sorts_hash[s.to_sym] = :asc
        end
      end
      active_sorts_hash
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
        params[filter.param].present? || filter.default || filter.always_active?
      }
    end
  end
end
