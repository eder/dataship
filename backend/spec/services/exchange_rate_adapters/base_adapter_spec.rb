# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExchangeRateAdapters::BaseAdapter, type: :service do
  let(:adapter) { described_class.new }

  describe '#fetch_rates' do
    it "raises NotImplementedError" do
      expect { adapter.fetch_rates }.to raise_error(NotImplementedError)
    end
  end

  describe '#adapter_name' do
    it "raises NotImplementedError" do
      expect { adapter.adapter_name }.to raise_error(NotImplementedError)
    end
  end

  describe '#available?' do
    it "raises NotImplementedError" do
      expect { adapter.available? }.to raise_error(NotImplementedError)
    end
  end

  describe '#normalize_currency' do
    it "normalizes currency strings" do
      expect(adapter.send(:normalize_currency, "usd")).to eq("USD")
      expect(adapter.send(:normalize_currency, " USD ")).to eq("USD")
      expect(adapter.send(:normalize_currency, :brl)).to eq("BRL")
    end
  end

  describe '#valid_rate?' do
    it "validates positive numeric rates" do
      expect(adapter.send(:valid_rate?, 1.5)).to be true
      expect(adapter.send(:valid_rate?, 0)).to be false
      expect(adapter.send(:valid_rate?, -1)).to be false
      expect(adapter.send(:valid_rate?, "invalid")).to be false
      expect(adapter.send(:valid_rate?, nil)).to be false
    end
  end
end
