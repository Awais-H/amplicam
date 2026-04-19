module Support
  class Money
    class << self
      def to_cents(value)
        return if value.nil?

        string = value.to_s.strip
        return if string.empty?

        normalized = string.gsub(/[^\d.\-]/, "")
        return if normalized.empty?

        (BigDecimal(normalized) * 100).round.to_i
      rescue ArgumentError
        nil
      end

      def to_decimal(cents)
        return if cents.nil?

        format("%.2f", cents.to_i / 100.0)
      end

      def payload(cents:, currency:)
        return if cents.nil? || currency.blank?

        {
          amount: to_decimal(cents),
          currency:
        }
      end
    end
  end
end

