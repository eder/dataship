# frozen_string_literal: true

module NotificationAdapters
  # Rails ActionCable notification adapter
  class RailsActionCableAdapter < BaseAdapter
    def notify(message, data = {})
      return false unless valid_notification_data?(message, data)

      channel_name = @config[:channel] || 'notifications_channel'
      payload = format_payload(message, data)

      ActionCable.server.broadcast(channel_name, payload)
      true
    rescue StandardError => e
      Rails.logger.error("ActionCable notification failed: #{e.message}")
      false
    end

    def adapter_name
      'rails_action_cable'
    end

    def available?
      defined?(ActionCable) && ActionCable.server.present?
    end
  end
end 