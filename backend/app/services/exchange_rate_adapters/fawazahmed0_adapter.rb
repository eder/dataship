# frozen_string_literal: true

require 'httparty'

module ExchangeRateAdapters
  # Adapter for the @fawazahmed0/currency-api service
  class Fawazahmed0Adapter < BaseAdapter
    def initialize(config = {})
      @date = config[:date] || ENV.fetch("EXCHANGE_API_DATE", "latest")
      @api_version = config[:api_version] || ENV.fetch("EXCHANGE_API_VERSION", "v1")
      @base_currency = config[:base_currency] || "usd"
      @desired_currencies = extract_desired_currencies(config)
    end

    def fetch_rates
      response = fetch_from_api
      return default_rates unless response.success?

      parse_rates(response.parsed_response)
    rescue StandardError => e
      Rails.logger.error "Error fetching rates from Fawazahmed0: #{e.message}"
      default_rates
    end

    def adapter_name
      'fawazahmed0'
    end

    def available?
      response = HTTParty.get(build_url, timeout: 5)
      response.success?
    rescue StandardError
      false
    end

    private

    attr_reader :date, :api_version, :base_currency, :desired_currencies

    def extract_desired_currencies(config)
      currencies = config[:currencies] || ENV.fetch("EXCHANGE_CURRENCIES", "usd,rub,inr,cny,zar,brl")
      currencies.split(',').map(&:strip).map(&:downcase)
    end

    def build_url
      "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@#{date}/#{api_version}/currencies/#{base_currency}.json"
    end

    def fetch_from_api
      HTTParty.get(build_url, timeout: 10)
    end

    def parse_rates(response_data)
      rates = { normalize_currency(base_currency) => 1.0 }
      base_rates = response_data[base_currency]

      desired_currencies.each do |currency|
        next if currency == base_currency

        rate = extract_rate(base_rates, currency)
        rates[normalize_currency(currency)] = rate if valid_rate?(rate)
      end

      rates
    end

    def extract_rate(base_rates, currency)
      return nil unless base_rates&.key?(currency)

      rate_data = base_rates[currency]
      rate_data.is_a?(Hash) ? rate_data["rate"] : rate_data
    end

    def default_rates
      desired_currencies.each_with_object({}) do |currency, rates|
        rates[normalize_currency(currency)] = nil
      end
    end
  end
end
