module Filterable
  # Filter describes the way a parameter maps to a database column
  # and the type information helpful for validating input.
  class Filter
    attr_reader :parameter, :default, :custom_validate, :scope_params

    def initialize(param, type, internal_name, default, custom_validate = nil, scope_params = [])
      @parameter = Parameter.new(param, type, internal_name)
      @default = default
      @custom_validate = custom_validate
      @scope_params = scope_params
      raise ArgumentError, 'scope_params must be an array of symbols' unless valid_scope_params?(scope_params)
      raise "unknown filter type: #{type}" unless type_validator.valid_type?
    end

    def validation(_)
      type_validator.validate
    end

    def apply!(collection, value:, active_sorts_hash:, params: {})
      if not_processable?(value)
        collection
      elsif should_apply_default?(value)
        default.call(collection)
      else
        parameter.handler.call(collection, parameterize(value), params, scope_params)
      end
    end

    def always_active?
      false
    end

    def validation_field
      parameter.param
    end

    def type_validator
      @type_validator ||= Filterable::TypeValidator.new(param, type)
    end

    def type
      parameter.type
    end

    def param
      parameter.param
    end

    private

    def not_processable?(value)
      value.nil? && default.nil?
    end

    def should_apply_default?(value)
      value.nil? && !default.nil?
    end

    def mapped_scope_params(params)
      scope_params.each_with_object({}) do |scope_param, hash|
        hash[scope_param] = params.fetch(scope_param)
      end
    end

    def parameterize(value)
      if parameter.supports_ranges? && value.to_s.include?('...')
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
