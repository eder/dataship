# frozen_string_literal: true

module NotificationAdapters
  # Interface/Contract for notification adapters
  class BaseAdapter
    # @param message [String] The notification message
    # @param data [Hash] Additional data to include in the notification
    # @return [Boolean] Whether the notification was sent successfully
    def notify(message, data = {})
      raise NotImplementedError, "#{self.class} must implement the #notify method"
    end

    # @return [String] Adapter name for identification
    def adapter_name
      raise NotImplementedError, "#{self.class} must implement the #adapter_name method"
    end

    # @return [Boolean] Whether the adapter is available/operational
    def available?
      raise NotImplementedError, "#{self.class} must implement the #available? method"
    end

    # @param config [Hash] Configuration for the adapter
    def initialize(config = {})
      @config = config
    end

    private

    # Helper to validate notification data
    def valid_notification_data?(message, data)
      message.is_a?(String) && !message.strip.empty? && data.is_a?(Hash)
    end

    # Helper to format notification payload
    def format_payload(message, data)
      {
        message: message,
        timestamp: Time.current.iso8601,
        data: data
      }
    end
  end
end 