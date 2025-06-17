# frozen_string_literal: true

module ExchangeRateAdapters
  # Factory to create exchange rate adapters
  class Factory
    ADAPTERS = {
      "fawazahmed0" => Fawazahmed0Adapter
      # Add new adapters here
      # 'exchangerate_api' => ExchangeRateApiAdapter,
      # 'fixer_io' => FixerIoAdapter,
    }.freeze

    class << self
      # @param adapter_name [String] Name of the adapter
      # @param config [Hash] Specific configuration for the adapter
      # @return [BaseAdapter] Instance of the adapter
      def create(adapter_name = nil, config = {})
        adapter_name ||= default_adapter_name
        adapter_class = ADAPTERS[adapter_name.to_s]

        raise ArgumentError, "Adapter '#{adapter_name}' not found" unless adapter_class

        adapter_class.new(config)
      end

      # @return [Array<String>] List of available adapters
      def available_adapters
        ADAPTERS.keys
      end

      # @param adapter_name [String] Name of the adapter
      # @return [Boolean] Whether the adapter is available
      def adapter_available?(adapter_name)
        ADAPTERS.key?(adapter_name.to_s)
      end

      private

      # @return [String] Default adapter name from environment or fallback
      def default_adapter_name
        ENV.fetch("EXCHANGE_RATE_ADAPTER", "fawazahmed0")
      end
    end
  end
end
