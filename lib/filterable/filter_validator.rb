# Here be dragons:
# there are two forms of metaprogramming in this file
# instance variables are being dynamically set based on the param name
# and we are class evaling `validates` to create dynamic validations
# based on the filters being validated.
module Filterable
  class FilterValidator
    include ActiveModel::Validations

    def initialize(filters, params)
      filters.each do |filter|
        instance_variable_set("@#{filter.param}", to_type(filter, params))
      end
      add_validations(filters, params)
    end

    private

    def to_type(filter, params)
      if filter.type == :boolean
        if Rails.version.starts_with?('5')
          ActiveRecord::Type::Boolean.new.cast(params[filter.param])
        else
          ActiveRecord::Type::Boolean.new.type_cast_from_user(params[filter.param])
        end
      else
        params[filter.param]
      end
    end

    def add_validations(filters, params)
      class_eval do
        attr_accessor(*filters.map(&:param))
        filters.each do |filter|
          if params[filter.param.to_sym] && filter.validation
            validates filter.param.to_sym, filter.validation
          end
        end
      end
    end
  end
end
