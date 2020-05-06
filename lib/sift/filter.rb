module Sift
  # Filter describes the way a parameter maps to a database column
  # and the type information helpful for validating input.
  class Filter
    attr_reader :parameter, :default, :custom_validate

    def self.scope_type?(type)
      type == :scope || type.respond_to?(:key?)
    end

    def initialize(param, type, internal_name, default, custom_validate = nil)
      @parameter = Parameter.new(param, type, internal_name)
      @default = default
      @custom_validate = custom_validate
      raise "unknown filter type: #{type}" unless type_validator.valid_type?
    end

    def validation(_sort)
      type_validator.validate
    end

    # rubocop:disable Lint/UnusedMethodArgument
    def apply!(collection, value:, active_sorts_hash:, params: {})
      if not_processable?(value)
        collection
      else
        default_or_handler(value, params).call(collection)
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
      @type_validator ||= Sift::TypeValidator.new(param, type)
    end

    def type
      parameter.type
    end

    def param
      parameter.param
    end

    protected

    # Subclasses should override. Default behavior is to return none
    def handler(_value, _params)
      ->(collection) { collection.none }
    end

    private

    def default_or_handler(value, params)
      if should_apply_default?(value)
        default
      else
        handler(value, params)
      end
    end

    def not_processable?(value)
      value.nil? && default.nil?
    end

    def should_apply_default?(value)
      value.nil? && !default.nil?
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
