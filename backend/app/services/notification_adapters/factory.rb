# frozen_string_literal: true

module NotificationAdapters
  # Factory for creating notification adapters
  class Factory
    ADAPTERS = {
      'rails_action_cable' => RailsActionCableAdapter,
      'aws_sns' => AwsSnsAdapter,
      'aws_sqs' => AwsSqsAdapter,
      'google_pubsub' => GooglePubsubAdapter
    }.freeze

    # @param adapter_name [String, nil] Name of the adapter to create
    # @param config [Hash] Configuration for the adapter
    # @return [BaseAdapter] The created adapter instance
    def self.create(adapter_name = nil, config = {})
      adapter_name ||= default_adapter_name
      
      adapter_class = ADAPTERS[adapter_name]
      raise ArgumentError, "Unknown adapter: #{adapter_name}" unless adapter_class

      adapter_class.new(config)
    end

    # @return [Array<String>] List of available adapter names
    def self.available_adapters
      ADAPTERS.keys
    end

    private

    # @return [String] Default adapter name based on environment
    def self.default_adapter_name
      Rails.env.test? ? 'rails_action_cable' : ENV.fetch('NOTIFICATION_ADAPTER', 'rails_action_cable')
    end
  end
end 