# Here be dragons:
# there are two forms of metaprogramming in this file
# instance variables are being dynamically set based on the param name
# and we are class evaling `validates` to create dynamic validations
# based on the filters being validated.
module Filterable
  class FilterValidator
    include ActiveModel::Validations

    attr_reader :filter_params, :sort_params

    def initialize(filters, params, sort_fields, filter_params:, sort_params:)
      @filter_params = filter_params
      @sort_params = sort_params

      filters.each do |filter|
        instance_variable_set("@#{filter.validation_field}", to_type(filter, params))
      end
      add_validations(filters, params, sort_fields)
    end

    private

    def to_type(filter, params)
      if filter.type == :boolean
        if Rails.version.starts_with?('5')
          ActiveRecord::Type::Boolean.new.cast(filter_params[filter.param])
        else
          ActiveRecord::Type::Boolean.new.type_cast_from_user(filter_params[filter.param])
        end
      elsif filter.validation_field == :sort
        params.fetch(:sort, '').split(',')
      else
        filter_params[filter.param]
      end
    end

    def add_validations(filters, params, sort_fields)
      unique_validations = filters.uniq { |filter| filter.validation_field }

      class_eval do
        attr_accessor(*unique_validations.map(&:validation_field))

        unique_validations.each do |filter|
          if (params.fetch(:filters, {})[filter.validation_field] && filter.custom_validate)
            validate filter.custom_validate
          elsif (params.fetch(:filters, {})[filter.validation_field] && filter.validation(sort_fields)) || filter.validation_field == :sort
            validates filter.validation_field.to_sym, filter.validation(sort_fields)
          end
        end
      end
    end
  end
end
