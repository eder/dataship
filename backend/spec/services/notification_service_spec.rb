# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationService do
  let(:config) { { channel: 'test_channel' } }
  let(:service) { described_class.new('rails_action_cable', config) }

  describe '#notify' do
    let(:message) { 'Test notification' }
    let(:data) { { status: 'success' } }

    it 'sends notification through the configured adapter' do
      expect_any_instance_of(NotificationAdapters::RailsActionCableAdapter)
        .to receive(:notify)
        .with(message, data)
        .and_return(true)

      result = service.notify(message, data)
      expect(result).to be true
    end

    it 'raises error when adapter is not available' do
      allow_any_instance_of(NotificationAdapters::RailsActionCableAdapter)
        .to receive(:available?)
        .and_return(false)

      expect { service.notify(message, data) }
        .to raise_error(StandardError, "Adapter 'rails_action_cable' is not available")
    end
  end

  describe '#adapter_name' do
    it 'returns the adapter name' do
      expect(service.adapter_name).to eq('rails_action_cable')
    end
  end

  describe '#adapter_available?' do
    it 'returns adapter availability status' do
      expect(service.adapter_available?).to be true
    end
  end
end 