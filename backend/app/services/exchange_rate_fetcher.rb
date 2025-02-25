require 'httparty'

class ExchangeRateFetcher
  include HTTParty

  def self.fetch_rates
    date = ENV.fetch("EXCHANGE_API_DATE", "latest")
    api_version = ENV.fetch("EXCHANGE_API_VERSION", "v1")
    desired_currencies = ENV.fetch("EXCHANGE_CURRENCIES", "usd,rub,inr,cny,zar,brl")
                              .split(',')
                              .map(&:strip)
                              .map(&:downcase)
    base_currency = "usd"

    url = "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@#{date}/#{api_version}/currencies/#{base_currency}.json"
    response = HTTParty.get(url)
    rates = {}
    if response.success?
      base_rates = response.parsed_response[base_currency]
      rates["USD"] = 1.0
      desired_currencies.each do |curr|
        next if curr == base_currency
        if base_rates[curr].is_a?(Hash)
          rates[curr.upcase] = base_rates[curr]["rate"]
        else
          rates[curr.upcase] = base_rates[curr] || nil
        end
      end
    else
      desired_currencies.each do |curr|
        rates[curr.upcase] = nil
      end
    end
    rates
  end
end

