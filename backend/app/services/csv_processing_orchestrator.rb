# frozen_string_literal: true

# Orchestrates the CSV processing workflow
class CsvProcessingOrchestrator
  # @param file_path [String] Path to the CSV file
  # @param notification_adapter [String, nil] Name of the notification adapter
  # @param notification_config [Hash] Configuration for the notification adapter
  def initialize(file_path, notification_adapter = nil, notification_config = {})
    @file_path = file_path
    @notification_adapter = notification_adapter
    @notification_config = notification_config
  end

  # @return [Boolean] Whether the processing was successful
  def process
    Rails.logger.info("Starting CSV processing for file: #{@file_path}")
    
    start_time = Time.current
    
    validate_file_exists
    exchange_rates = fetch_exchange_rates
    process_csv_file(exchange_rates)
    
    end_time = Time.current
    processing_duration = (end_time - start_time).round(2)
    
    # Ensure all database operations are committed before sending notification
    ActiveRecord::Base.connection.commit_db_transaction if ActiveRecord::Base.connection.transaction_open?
    
    notify_success(processing_duration)
    Rails.logger.info("Completed CSV processing for file: #{@file_path} in #{processing_duration} seconds")
    true
  rescue StandardError => e
    Rails.logger.error("Error in CSV processing for file #{@file_path}: #{e.message}")
    notify_error(e)
    raise e
  end

  private

  # @return [Hash<String, Float>] Exchange rates
  def fetch_exchange_rates
    Rails.logger.info("Fetching exchange rates...")
    rates = ExchangeRateFetcher.fetch_rates
    Rails.logger.info("Exchange rates fetched successfully")
    rates
  end

  # @param exchange_rates [Hash<String, Float>] Exchange rates for conversion
  def process_csv_file(exchange_rates)
    Rails.logger.info("Processing CSV file with exchange rates: #{@file_path}")
    
    # Get file size for logging
    file_size = File.size(@file_path)
    file_size_mb = (file_size / 1024.0 / 1024.0).round(2)
    Rails.logger.info("File size: #{file_size_mb} MB")
    
    CsvProcessor.new(@file_path, exchange_rates).process
    Rails.logger.info("CSV processing completed: #{@file_path}")
  end

  def notify_success(processing_duration)
    Rails.logger.info("Sending success notification for file: #{@file_path}")
    notification_service.notify(
      "File processing finished successfully",
      {
        file: @file_path,
        status: "success",
        processed_at: Time.current.iso8601,
        processing_duration: processing_duration
      }
    )
    Rails.logger.info("Success notification sent for file: #{@file_path}")
  end

  # @param error [StandardError] The error that occurred
  def notify_error(error)
    Rails.logger.error("Sending error notification for file: #{@file_path}")
    notification_service.notify(
      "Error processing file",
      {
        file: @file_path,
        status: "error",
        error: error.message,
        error_class: error.class.name,
        failed_at: Time.current.iso8601
      }
    )
    Rails.logger.error("Error notification sent for file: #{@file_path}")
  end

  # @return [NotificationService] The notification service instance
  def notification_service
    @notification_service ||= NotificationService.new(@notification_adapter, @notification_config)
  end

  def validate_file_exists
    return if File.exist?(@file_path)

    raise ArgumentError, "File not found: #{@file_path}"
  end
end 