# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExchangeRateAdapters::Fawazahmed0Adapter, type: :service do
  let(:config) { {} }
  let(:adapter) { described_class.new(config) }

  describe '#adapter_name' do
    it "returns the correct adapter name" do
      expect(adapter.adapter_name).to eq('fawazahmed0')
    end
  end

  describe '#fetch_rates' do
    let(:fake_response) do
      {
        "usd" => {
          "rub" => 88.81525395,
          "inr" => 86.69044436,
          "cny" => 7.25113273,
          "zar" => 18.36307,
          "brl" => 5.71473278
        }
      }
    end

    let(:expected_rates) do
      {
        "USD" => 1.0,
        "RUB" => 88.81525395,
        "INR" => 86.69044436,
        "CNY" => 7.25113273,
        "ZAR" => 18.36307,
        "BRL" => 5.71473278
      }
    end

    context "when API call is successful" do
      before do
        allow(HTTParty).to receive(:get).and_return(
          double(success?: true, parsed_response: fake_response)
        )
      end

      it "returns parsed rates" do
        rates = adapter.fetch_rates
        expect(rates).to eq(expected_rates)
      end

      it "handles complex rate structures" do
        complex_response = {
          "usd" => {
            "rub" => { "rate" => 88.81525395 },
            "inr" => 86.69044436
          }
        }

        allow(HTTParty).to receive(:get).and_return(
          double(success?: true, parsed_response: complex_response)
        )

        rates = adapter.fetch_rates
        expect(rates["RUB"]).to eq(88.81525395)
        expect(rates["INR"]).to eq(86.69044436)
      end
    end

    context "when API call fails" do
      before do
        allow(HTTParty).to receive(:get).and_return(
          double(success?: false)
        )
      end

      it "returns default rates with nil values" do
        rates = adapter.fetch_rates
        expect(rates).to eq({
          "USD" => nil,
          "RUB" => nil,
          "INR" => nil,
          "CNY" => nil,
          "ZAR" => nil,
          "BRL" => nil
        })
      end
    end

    context "when API call raises an error" do
      before do
        allow(HTTParty).to receive(:get).and_raise(StandardError, "Network error")
      end

      it "returns default rates and logs error" do
        expect(Rails.logger).to receive(:error).with(/Error fetching rates from Fawazahmed0: Network erro/)
        rates = adapter.fetch_rates
        expect(rates.values).to all(be_nil)
      end
    end
  end

  describe '#available?' do
    context "when API is reachable" do
      before do
        allow(HTTParty).to receive(:get).and_return(double(success?: true))
      end

      it "returns true" do
        expect(adapter.available?).to be true
      end
    end

    context "when API is not reachable" do
      before do
        allow(HTTParty).to receive(:get).and_raise(StandardError)
      end

      it "returns false" do
        expect(adapter.available?).to be false
      end
    end
  end

  describe "configuration" do
    context "with custom config" do
      let(:config) do
        {
          date: "2024-01-01",
          api_version: "v2",
          base_currency: "eur",
          currencies: "usd,gbp,jpy"
        }
      end

      it "uses custom configuration" do
        expect(adapter.send(:date)).to eq("2024-01-01")
        expect(adapter.send(:api_version)).to eq("v2")
        expect(adapter.send(:base_currency)).to eq("eur")
        expect(adapter.send(:desired_currencies)).to eq([ "usd", "gbp", "jpy" ])
      end
    end

    context "with environment variables" do
      before do
        ENV["EXCHANGE_API_DATE"] = "2024-01-01"
        ENV["EXCHANGE_API_VERSION"] = "v2"
        ENV["EXCHANGE_CURRENCIES"] = "usd,gbp,jpy"
      end

      after do
        ENV.delete("EXCHANGE_API_DATE")
        ENV.delete("EXCHANGE_API_VERSION")
        ENV.delete("EXCHANGE_CURRENCIES")
      end

      it "uses environment variables as fallback" do
        adapter = described_class.new
        expect(adapter.send(:date)).to eq("2024-01-01")
        expect(adapter.send(:api_version)).to eq("v2")
        expect(adapter.send(:desired_currencies)).to eq([ "usd", "gbp", "jpy" ])
      end
    end
  end
end
