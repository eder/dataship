# frozen_string_literal: true

module NotificationAdapters
  # Google Cloud Pub/Sub notification adapter
  class GooglePubsubAdapter < BaseAdapter
    def notify(message, data = {})
      return false unless valid_notification_data?(message, data)

      topic_name = @config[:topic_name]
      raise ArgumentError, "topic_name is required for Google Pub/Sub adapter" unless topic_name

      payload = format_payload(message, data)

      pubsub_client.publish(
        topic_name,
        payload.to_json
      )
      true
    rescue StandardError => e
      Rails.logger.error("Google Pub/Sub notification failed: #{e.message}")
      false
    end

    def adapter_name
      "google_pubsub"
    end

    def available?
      defined?(Google::Cloud::Pubsub) && @config[:topic_name].present?
    end

    private

    def pubsub_client
      @pubsub_client ||= Google::Cloud::Pubsub.new(
        project_id: @config[:project_id],
        credentials: @config[:credentials]
      )
    end
  end
end
