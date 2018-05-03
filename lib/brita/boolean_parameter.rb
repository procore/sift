module Brita
  class BooleanParameter < Parameter

    def parse(value)
      if Rails.version.starts_with?("5")
        ActiveRecord::Type::Boolean.new.cast(value)
      else
        ActiveRecord::Type::Boolean.new.type_cast_from_user(value)
      end
    end
  end
end
