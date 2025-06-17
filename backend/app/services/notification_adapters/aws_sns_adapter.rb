# frozen_string_literal: true

module NotificationAdapters
  # AWS SNS notification adapter
  class AwsSnsAdapter < BaseAdapter
    def notify(message, data = {})
      return false unless valid_notification_data?(message, data)

      topic_arn = @config[:topic_arn]
      raise ArgumentError, 'topic_arn is required for AWS SNS adapter' unless topic_arn

      payload = format_payload(message, data)
      
      sns_client.publish(
        topic_arn: topic_arn,
        message: payload.to_json,
        subject: data[:subject] || 'CSV Processing Notification'
      )
      true
    rescue StandardError => e
      Rails.logger.error("AWS SNS notification failed: #{e.message}")
      false
    end

    def adapter_name
      'aws_sns'
    end

    def available?
      defined?(Aws::SNS) && @config[:topic_arn].present?
    end

    private

    def sns_client
      @sns_client ||= Aws::SNS::Client.new(
        region: @config[:region] || 'us-east-1',
        credentials: Aws::Credentials.new(
          @config[:access_key_id],
          @config[:secret_access_key]
        )
      )
    end
  end
end 