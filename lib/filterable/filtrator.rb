module Filterable
  # Filtrator takes a collection, params and a set of filters
  # and applies them to create a new active record collection
  # with those filters applied.
  class Filtrator
    attr_reader :collection, :params, :filters, :sort

    def self.filter(collection, filter_params, filters, sort = "")
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
      if filter.type == :scope
        apply_scope_filters(collection, filter)
      else
        filter.apply!(collection, value: params[filter.param], sorts: sort)
      end
    end

    def apply_scope_filters(collection, filter)
      if filter.is_a?(Filterable::Filter)
        apply_scope_filterable_filter(collection, filter)
      else
        apply_scope_filterable_sort(collection, filter)
      end
    end

    # Method that is called with a Filterable::Filter of type :scope
    def apply_scope_filterable_filter(collection, filter)
      if params[filter.param].present?
        collection.public_send(filter.internal_name, parameter(filter))
      elsif filter.default.present?
        filter.default.call(collection)
      else
        collection
      end
    end

    # Method that is called with a Filterable::Sort of type :scope
    def apply_scope_filterable_sort(collection, sort)
      # This shouldnt be params[sort.params]
      if active_sorts.keys.include?(sort.param)
        collection.public_send(sort.internal_name, *sort_scope_params(sort))
      elsif sort.default.present?
        # Stubbed because currently Filterable::Sort does not respect default
        # sort.default.call(collection)
        collection
      else
        collection
      end
    end

    def sort_scope_params(sort)
      sort.scope_params.map{ |param| param == :direction ? active_sorts[sort.param] : param }
    end

    def active_sorts
      active_sorts = {}
      self.sort.each do |s|
        if s.starts_with?('-')
          active_sorts[s[1..-1].to_sym] = :desc
        else
          active_sorts[s.to_sym] = :asc
        end
      end
      active_sorts
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
