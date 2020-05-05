# frozen_string_literal: true

module Sift
  class Filter
    class Scope < Sift::Filter
      attr_reader :scope_params, :scope_types

      def initialize(param, raw_type, internal_name, default, custom_validate = nil, scope_params = [])
        super(param, :scope, internal_name, default, custom_validate)
        @scope_types = []
        @scope_params = scope_params || []
        raise ArgumentError, "scope_params must be an array of symbols" unless valid_scope_params?(scope_params)

        if raw_type.respond_to?(:key?)
          @scope_types = Array(raw_type[:scope]).compact
          validate_scope_types!

          @type_validator = Sift::TypeValidator.new(param, @scope_types.first || :scope)
        end
      end

      protected

      def handler(value, params)
        Sift::ScopeHandler.new(value, mapped_scope_params(params), parameter, scope_types)
      end

      private

      def mapped_scope_params(params)
        scope_params.each_with_object({}) do |scope_param, hash|
          hash[scope_param] = params.fetch(scope_param)
        end
      end

      def valid_scope_params?(scope_params)
        scope_params.is_a?(Array) && scope_params.all? { |symbol| symbol.is_a?(Symbol) }
      end

      def validate_scope_types!
        return if scope_types.empty?

        unless Sift::TypeValidator.new(parameter.param, scope_types.first).valid_type?
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
    end
  end
end
