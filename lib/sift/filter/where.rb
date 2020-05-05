# frozen_string_literal: true

module Sift
  class Filter
    class Where < Sift::Filter
      protected

      def handler(value, _params)
        Sift::WhereHandler.new(value, parameter)
      end
    end
  end
end
