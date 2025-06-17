# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationAdapters::RailsActionCableAdapter do
  let(:config) { { channel: 'test_channel' } }
  let(:adapter) { described_class.new(config) }

  describe '#notify' do
    let(:message) { 'Test message' }
    let(:data) { { status: 'success' } }

    it 'broadcasts message through ActionCable' do
      expect(ActionCable.server).to receive(:broadcast)
        .with('test_channel', hash_including(:message, :timestamp, :data))

      result = adapter.notify(message, data)
      expect(result).to be true
    end

    it 'returns false for invalid message' do
      result = adapter.notify('', data)
      expect(result).to be false
    end

    it 'returns false for invalid data' do
      result = adapter.notify(message, 'invalid')
      expect(result).to be false
    end

    it 'handles ActionCable errors gracefully' do
      allow(ActionCable.server).to receive(:broadcast).and_raise(StandardError, 'Test error')

      result = adapter.notify(message, data)
      expect(result).to be false
    end
  end

  describe '#adapter_name' do
    it 'returns the correct adapter name' do
      expect(adapter.adapter_name).to eq('rails_action_cable')
    end
  end

  describe '#available?' do
    it 'returns true when ActionCable is available' do
      expect(adapter.available?).to be true
    end
  end
end 