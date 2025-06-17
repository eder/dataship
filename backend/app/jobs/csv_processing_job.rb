# frozen_string_literal: true

# Job responsible for processing CSV files with exchange rate conversion
class CsvProcessingJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 5.seconds, attempts: 5

  # @param file_path [String] Path to the CSV file to process
  # @param notification_adapter [String, nil] Name of the notification adapter to use
  # @param notification_config [Hash] Configuration for the notification adapter
  def perform(file_path, notification_adapter = nil, notification_config = {})
    Rails.logger.info("Starting processing of file: #{file_path}")

    orchestrator = CsvProcessingOrchestrator.new(file_path, notification_adapter, notification_config)
    orchestrator.process

    Rails.logger.info("Successfully processed file: #{file_path}")
  rescue StandardError => e
    Rails.logger.error("Error processing file #{file_path}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise e
  end
end
