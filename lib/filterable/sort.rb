module Filterable
  class FunkyArray
    def initialize(array)
      @array = array
    end

    def include?(other)
      @array.to_set >= other.to_set
    end
  end

  # TODO docs comment
  class Sort

    attr_reader :param, :type, :internal_name

    WHITELIST_TYPES = [:int,
                       :decimal,
                       :string,
                       :text,
                       :date,
                       :time,
                       :datetime].freeze

    def initialize(param, type, internal_name = param)
      raise "unknown filter type: #{type}" unless WHITELIST_TYPES.include?(type)
      self.param = param
      self.type = type
      self.internal_name = internal_name
    end

    def default
      # TODO: we can support defaults here later
      false
    end

    def apply!(collection, _, sorts)
      collection.order(order_hash(sorts))
    end

    def always_active?
      true
    end

    def validation_field
      :sort
    end

    def validation(sort)
      {inclusion: { in: FunkyArray.new(sort) }, allow_nil: true }
    end



    private

    attr_writer :param, :type, :internal_name

    def order_hash(sorts)
      sorts.reduce({}) { |order_hash, raw_field|
        if raw_field.starts_with?('-')
          if raw_field[1..-1] == param.to_s
            order_hash[raw_field[1..-1]] = :desc
          end
        else
          if raw_field == param.to_s
            order_hash[raw_field] = :asc
          end
        end
        order_hash
      }
    end
  end
end
