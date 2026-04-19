module Types
  module Scalars
    class DecimalType < GraphQL::Schema::Scalar
      description "Decimal value serialized as a string to preserve precision."

      def self.coerce_input(input_value, _context)
        BigDecimal(input_value.to_s)
      rescue ArgumentError
        nil
      end

      def self.coerce_result(ruby_value, _context)
        ruby_value.to_s
      end
    end
  end
end

