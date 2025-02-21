require 'httparty'

class ExchangeRateFetcher
  include HTTParty

  def self.fetch_rates
    date = ENV.fetch("EXCHANGE_API_DATE", "latest")
    api_version = ENV.fetch("EXCHANGE_API_VERSION", "v1")
    currencies = ENV.fetch("EXCHANGE_CURRENCIES", "eur,gbp,jpy,aud,cad").split(',')

    rates = {}
    currencies.each do |currency|
      url = "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@#{date}/#{api_version}/currencies/#{currency}.json"
      response = HTTParty.get(url)
      if response.success?
        rates[currency] = response.parsed_response
      else
        rates[currency] = {}
      end
    end
    { fetched_at: Time.current, rates: rates }
  end
end
