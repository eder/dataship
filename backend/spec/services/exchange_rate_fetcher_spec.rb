require 'rails_helper'

RSpec.describe ExchangeRateFetcher, type: :service do
  it "returns a flat hash with exchange rates" do
    # Simulate an API response for the base currency "usd"
    fake_response = {
      "usd" => {
        "rub" => 88.81525395,
        "inr" => 86.69044436,
        "cny" => 7.25113273,
        "zar" => 18.36307,
        "brl" => 5.71473278
      }
    }

   # Use WebMock or allow/expect to stub HTTParty.get
    allow(HTTParty).to receive(:get).and_return(double(success?: true, parsed_response: fake_response))

    rates = ExchangeRateFetcher.fetch_rates
    expect(rates).to eq({
      "USD" => 1.0,
      "RUB" => 88.81525395,
      "INR" => 86.69044436,
      "CNY" => 7.25113273,
      "ZAR" => 18.36307,
      "BRL" => 5.71473278
    })
  end
end

