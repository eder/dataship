# frozen_string_literal: true

require 'httparty'

class ExchangeRateFetcher
  include HTTParty

  # @param adapter_name [String] Name of the adapter to be used
  # @param config [Hash] Specific configuration for the adapter
  def initialize(adapter_name = nil, config = {})
    @adapter = ExchangeRateAdapters::Factory.create(adapter_name, config)
  end

  # @return [Hash<String, Float>] Exchange rates
  def fetch_rates
    validate_adapter_availability
    @adapter.fetch_rates
  end

  # @return [String] Name of the current adapter
  def adapter_name
    @adapter.adapter_name
  end

  # @return [Boolean] Whether the adapter is available
  def adapter_available?
    @adapter.available?
  end

  # Class method for compatibility with existing code
  # @return [Hash<String, Float>] Exchange rates
  def self.fetch_rates
    new.fetch_rates
  end

  private

  def validate_adapter_availability
    return if adapter_available?

    raise StandardError, "Adapter '#{adapter_name}' is not available"
  end
end