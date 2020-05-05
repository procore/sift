module Sift
  class ScopeHandler
    def initialize(raw_value, raw_scope_options, parameter, scope_types)
      @value = ValueParser.new(value: raw_value, type: scope_types.first || parameter).parse
      @param = parameter
      @scope_options = parsed_scope_options(raw_scope_options, scope_types)
    end

    def call(collection)
      collection.public_send(@param.internal_name, *scope_parameters)
    end

    private

    def scope_parameters
      if @scope_options.present?
        [@value, @scope_options]
      else
        [@value]
      end
    end

    def parsed_scope_options(raw_scope_options, scope_types)
      return nil if raw_scope_options.empty?

      scope_option_types = scope_types[1] || {}
      raw_scope_options.each_with_object({}) do |(key, raw_param), hash|
        hash[key] =
          if scope_option_types[key].present?
            ValueParser.new(value: raw_param, type: scope_option_types[key]).parse
          else
            raw_param
          end
      end
    end
  end
end
