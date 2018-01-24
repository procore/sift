module Filterable
  # Value Object that wraps some handling of filter params
  class Parameter
    attr_reader :param, :type, :internal_name

    def initialize(param, type, internal_name = param)
      @param = param
      @type = type
      @internal_name = internal_name
    end

    def supports_ranges?
      ![:string, :text, :scope].include?(type)
    end

    def handler
      if type == :scope
        ScopeHandler.new(self)
      else
        WhereHandler.new(self)
      end
    end
  end

  class ScopeHandler
    def initialize(param)
      @param = param
    end

    def call(collection, value, params, default, scope_params)
      if value.present?
        apply_scope_with_value(collection, value, params, scope_params)
      elsif default.present?
        default.call(collection)
      end
    end

    def apply_scope_with_value(collection, value, params, scope_params)
      collection.public_send(@param.internal_name, *scope_parameters(value, params, scope_params))
    end

    def scope_parameters(value, params, scope_params)
      if scope_params.empty?
        [value]
      else
        [value, mapped_scope_params(params, scope_params)]
      end
    end

    def mapped_scope_params(params, scope_params)
      scope_params.each_with_object({}) do |scope_param, hash|
        hash[scope_param] = params.fetch(scope_param)
      end
    end


  end

  class WhereHandler
    def initialize(param)
      @param = param
    end

    def call(collection, value, params, default, scope_params)
      collection.where(@param.internal_name => value)
    end
  end
end
