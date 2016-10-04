module Filterable
  # TODO docs comment
  class Sort

    attr_reader :param, :type, :internal_name

    WHITELIST_TYPES = [:int,
                       :decimal,
                       :boolean,
                       :string,
                       :text,
                       :date,
                       :time,
                       :datetime,
                       :scope].freeze
    def initialize(param, type, internal_name = param)
      raise "unknown filter type: #{type}" unless WHITELIST_TYPES.include?(type)
      self.param = param.to_s
      self.type = type
      self.internal_name = internal_name
    end

    private

    attr_writer :param, :type, :internal_name


  end
end
