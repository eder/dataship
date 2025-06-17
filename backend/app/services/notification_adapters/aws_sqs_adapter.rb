# frozen_string_literal: true

module NotificationAdapters
  # AWS SQS notification adapter
  class AwsSqsAdapter < BaseAdapter
    def notify(message, data = {})
      return false unless valid_notification_data?(message, data)

      queue_url = @config[:queue_url]
      raise ArgumentError, "queue_url is required for AWS SQS adapter" unless queue_url

      payload = format_payload(message, data)

      sqs_client.send_message(
        queue_url: queue_url,
        message_body: payload.to_json
      )
      true
    rescue StandardError => e
      Rails.logger.error("AWS SQS notification failed: #{e.message}")
      false
    end

    def adapter_name
      "aws_sqs"
    end

    def available?
      defined?(Aws::SQS) && @config[:queue_url].present?
    end

    private

    def sqs_client
      @sqs_client ||= Aws::SQS::Client.new(
        region: @config[:region] || "us-east-1",
        credentials: Aws::Credentials.new(
          @config[:access_key_id],
          @config[:secret_access_key]
        )
      )
    end
  end
end
