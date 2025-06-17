# frozen_string_literal: true

# Service responsible for sending notifications through configured adapters
class NotificationService
  # @param adapter_name [String] Name of the adapter to be used
  # @param config [Hash] Specific configuration for the adapter
  def initialize(adapter_name = nil, config = {})
    @adapter = NotificationAdapters::Factory.create(adapter_name, config)
  end

  # @param message [String] The notification message
  # @param data [Hash] Additional data to include in the notification
  # @return [Boolean] Whether the notification was sent successfully
  def notify(message, data = {})
    validate_adapter_availability
    @adapter.notify(message, data)
  end

  # @return [String] Name of the current adapter
  def adapter_name
    @adapter.adapter_name
  end

  # @return [Boolean] Whether the adapter is available
  def adapter_available?
    @adapter.available?
  end

  private

  def validate_adapter_availability
    return if adapter_available?

    raise StandardError, "Adapter '#{adapter_name}' is not available"
  end
end
