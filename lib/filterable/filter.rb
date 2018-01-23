module Filterable
  # Filter describes the way a parameter maps to a database column
  # and the type information helpful for validating input.
  class Filter
    attr_reader :param, :type, :internal_name, :default, :custom_validate, :scope_params

    def initialize(param, type, internal_name, default, custom_validate = nil, scope_params = [])
      @param = param
      @type = type
      @internal_name = internal_name || @param
      @default = default
      @custom_validate = custom_validate
      @scope_params = scope_params
      raise ArgumentError, 'scope_params must be an array of symbols' unless valid_scope_params?(scope_params)
      raise "unknown filter type: #{type}" unless type_validator.valid_type?
    end

    def supports_ranges?
      ![:string, :text, :scope].include?(type)
    end

    def validation(_)
      type_validator.validate
    end

    def apply!(collection, value:, active_sorts_hash:, params: {})
      if not_processable?(value)
        collection
      elsif type == :scope
        apply_scope(collection, value, params)
      else
        collection.where(internal_name => parameter(value))
      end
    end

    def always_active?
      false
    end

    def validation_field
      param
    end

    def type_validator
      @type_validator ||= Filterable::TypeValidator.new(param, type)
    end

    private

    def apply_scope(collection, value, params)
      if value.present?
        apply_scope_with_value(collection, value, params)
      elsif default.present?
        default.call(collection)
      end
    end

    def apply_scope_with_value(collection, value, params)
      collection.public_send(internal_name, *scope_parameters(value, params))
    end

    def scope_parameters(value, params)
      if scope_params.empty?
        [parameter(value)]
      else
        [parameter(value), mapped_scope_params(params)]
      end
    end

    def not_processable?(value)
      value.nil? && default.nil?
    end

    def mapped_scope_params(params)
      scope_params.each_with_object({}) do |scope_param, hash|
        hash[scope_param] = params.fetch(scope_param)
      end
    end

    def parameter(value)
      if supports_ranges? && value.to_s.include?('...')
        Range.new(*value.split('...'))
      elsif type == :boolean
        if Rails.version.starts_with?('5')
          ActiveRecord::Type::Boolean.new.cast(value)
        else
          ActiveRecord::Type::Boolean.new.type_cast_from_user(value)
        end
      else
        value
      end
    end

    def valid_scope_params?(scope_params)
      scope_params.is_a?(Array) && scope_params.all? { |symbol| symbol.is_a?(Symbol) }
    end
  end
end
