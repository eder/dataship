# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationAdapters::Factory do
  describe '.create' do
    it 'creates rails_action_cable adapter' do
      adapter = described_class.create('rails_action_cable')
      expect(adapter).to be_a(NotificationAdapters::RailsActionCableAdapter)
    end

    it 'creates aws_sns adapter' do
      adapter = described_class.create('aws_sns')
      expect(adapter).to be_a(NotificationAdapters::AwsSnsAdapter)
    end

    it 'creates aws_sqs adapter' do
      adapter = described_class.create('aws_sqs')
      expect(adapter).to be_a(NotificationAdapters::AwsSqsAdapter)
    end

    it 'creates google_pubsub adapter' do
      adapter = described_class.create('google_pubsub')
      expect(adapter).to be_a(NotificationAdapters::GooglePubsubAdapter)
    end

    it 'raises error for unknown adapter' do
      expect { described_class.create('unknown') }
        .to raise_error(ArgumentError, 'Unknown adapter: unknown')
    end

    it 'uses default adapter when no adapter specified' do
      adapter = described_class.create
      expect(adapter).to be_a(NotificationAdapters::RailsActionCableAdapter)
    end
  end

  describe '.available_adapters' do
    it 'returns list of available adapters' do
      adapters = described_class.available_adapters
      expect(adapters).to include('rails_action_cable', 'aws_sns', 'aws_sqs', 'google_pubsub')
    end
  end
end
