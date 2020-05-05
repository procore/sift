module Sift
  # Filter describes the way a parameter maps to a database column
  # and the type information helpful for validating input.
  class Filter
    attr_reader :parameter, :default, :custom_validate, :scope_params, :scope_types

    def initialize(param, type, internal_name, default, custom_validate = nil, scope_params = [], scope_types = [])
      @parameter = Parameter.new(param, type, internal_name)
      @default = default
      @custom_validate = custom_validate
      @scope_params = scope_params
      @scope_types = Array(scope_types)
      raise ArgumentError, "scope_params must be an array of symbols" unless valid_scope_params?(scope_params)
      raise "unknown filter type: #{type}" unless type_validator.valid_type?

      validate_scope_types!
    end

    def validation(_sort)
      type_validator.validate
    end

    # rubocop:disable Lint/UnusedMethodArgument
    def apply!(collection, value:, active_sorts_hash:, params: {})
      if not_processable?(value)
        collection
      else
        handler(value, params).call(collection)
      end
    end
    # rubocop:enable Lint/UnusedMethodArgument

    def always_active?
      false
    end

    def validation_field
      parameter.param
    end

    def type_validator
      @type_validator ||= Sift::TypeValidator.new(param, validation_type)
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

    def valid_scope_params?(scope_params)
      scope_params.is_a?(Array) && scope_params.all? { |symbol| symbol.is_a?(Symbol) }
    end

    def handler(value, params)
      if should_apply_default?(value)
        default
      elsif type == :scope
        Sift::ScopeHandler.new(value, mapped_scope_params(params), parameter, scope_types)
      else
        Sift::WhereHandler.new(value, parameter)
      end
    end

    def validate_scope_types!
      return if scope_types.empty?

      unless Sift::TypeValidator.new(param, scope_types.first).valid_type?
        raise ArgumentError, "scope_types must contain a valid filter type for the scope parameter"
      end
      return if scope_types.size == 1

      if scope_types.size > 2 || !valid_scope_option_types!(scope_types[1])
        raise ArgumentError, "type: scope: expected to have this structure: [type, {#{scope_params.map { |sp| "#{sp}: type" }.join(', ')}}]"
      end
    end

    def valid_scope_option_types!(hash)
      valid_form = hash.respond_to?(:keys) && hash.all? { |key, value| Sift::TypeValidator.new(key, value).valid_type? }
      if valid_form && scope_params.empty?
        # default scope_params
        @scope_params = hash.keys
      end
      valid_form && (hash.keys - scope_params).empty?
    end

    def validation_type
      if type != :scope || scope_types.empty?
        type
      else
        scope_types.first
      end
    end
  end
end
