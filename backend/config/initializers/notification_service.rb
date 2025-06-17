# frozen_string_literal: true

# Configuration for notification service
Rails.application.config.after_initialize do
  # Set default notification adapter based on environment
  default_adapter = case Rails.env
                   when 'production'
                     ENV.fetch('NOTIFICATION_ADAPTER', 'aws_sns')
                   when 'staging'
                     ENV.fetch('NOTIFICATION_ADAPTER', 'aws_sqs')
                   else
                     'rails_action_cable'
                   end

  # Store default configuration
  Rails.application.config.default_notification_adapter = default_adapter
  Rails.application.config.notification_config = {
    'aws_sns' => {
      topic_arn: ENV['AWS_SNS_TOPIC_ARN'],
      region: ENV['AWS_REGION'] || 'us-east-1',
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    },
    'aws_sqs' => {
      queue_url: ENV['AWS_SQS_QUEUE_URL'],
      region: ENV['AWS_REGION'] || 'us-east-1',
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    },
    'google_pubsub' => {
      project_id: ENV['GOOGLE_CLOUD_PROJECT_ID'],
      topic_name: ENV['GOOGLE_PUBSUB_TOPIC_NAME'],
      credentials: ENV['GOOGLE_CLOUD_CREDENTIALS']
    },
    'rails_action_cable' => {
      channel: ENV['ACTION_CABLE_CHANNEL'] || 'notifications_channel'
    }
  }
end 