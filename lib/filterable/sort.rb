module Filterable
  # Sort provides the same interface as a filter,
  # but instead of applying a `where` to the collection
  # it applies an `order`.
  class Sort
    attr_reader :param, :type, :internal_name, :scope_params

    WHITELIST_TYPES = [:int,
                       :decimal,
                       :string,
                       :text,
                       :date,
                       :time,
                       :datetime,
                       :scope].freeze

    def initialize(param, type, internal_name = param, scope_params = [])
      raise "unknown filter type: #{type}" unless WHITELIST_TYPES.include?(type)
      raise "scope params must be an array" unless scope_params.is_a?(Array)
      @param = param
      @type = type
      @internal_name = internal_name
      @scope_params = scope_params
    end

    def default
      # TODO: we can support defaults here later
      false
    end

    def apply!(collection, sorts:, value:)
      collection.order(order_hash(sorts))
    end

    def always_active?
      true
    end

    def validation_field
      :sort
    end

    def validation(sort)
      {
        inclusion: { in: SubsetComparator.new(sort) },
        allow_nil: true
      }
    end

    private

    def order_hash(sorts)
      sorts.reduce({}) { |order_hash, raw_field|
        if raw_field.starts_with?('-')
          if raw_field[1..-1] == param.to_s
            order_hash[internal_name] = :desc
          end
        else
          if raw_field == param.to_s
            order_hash[internal_name] = :asc
          end
        end
        order_hash
      }
    end
  end
end
