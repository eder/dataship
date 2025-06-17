# frozen_string_literal: true

# Configuration for CSV processing
Rails.application.config.after_initialize do
  # Set default batch size for CSV processing
  ENV["CSV_BATCH_SIZE"] ||= "1000"

  # Set maximum lines to process (default: 1M lines)
  ENV["CSV_MAX_LINES"] ||= "1000000"

  Rails.logger.info("CSV processing configuration loaded")
  Rails.logger.info("CSV_BATCH_SIZE: #{ENV['CSV_BATCH_SIZE']}")
  Rails.logger.info("CSV_MAX_LINES: #{ENV['CSV_MAX_LINES']}")
end
