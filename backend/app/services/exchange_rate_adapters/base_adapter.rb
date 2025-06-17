# frozen_string_literal: true

module ExchangeRateAdapters
  # Interface/Contract for exchange rate adapters
  class BaseAdapter
    # @return [Hash<String, Float>] Exchange rates in the format { "USD" => 1.0, "BRL" => 5.0 }
    def fetch_rates
      raise NotImplementedError, "#{self.class} must implement the #fetch_rates method"
    end

    # @return [String] Adapter name for identification
    def adapter_name
      raise NotImplementedError, "#{self.class} must implement the #adapter_name method"
    end

    # @return [Boolean] Whether the adapter is available/operational
    def available?
      raise NotImplementedError, "#{self.class} must implement the #available? method"
    end

    private

    # Helper to normalize currency codes
    def normalize_currency(currency)
      currency.to_s.strip.upcase
    end

    # Helper to validate a rate value
    def valid_rate?(rate)
      rate.is_a?(Numeric) && rate.positive?
    end
  end
end