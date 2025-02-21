class CsvProcessingJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 5.seconds, attempts: 5

  def perform(file_path)
    Rails.logger.info("Starting processing of file: #{file_path}")
    exchange_rates = ExchangeRateFetcher.fetch_rates
    CsvProcessor.new(file_path, exchange_rates).process
    Rails.logger.info("Successfully processed file: #{file_path}")

    # Broadcast success notification
    ActionCable.server.broadcast "notifications_channel", {
      message: "File processing finished successfully",
      file: file_path,
      status: "success"
    }
  rescue StandardError => e
    Rails.logger.error("Error processing file #{file_path}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))

    # Broadcast error notification
    ActionCable.server.broadcast "notifications_channel", {
      message: "Error processing file",
      error: e.message,
      file: file_path,
      status: "error"
    }
    raise e
  end
end

