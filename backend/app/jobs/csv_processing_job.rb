class CsvProcessingJob < ApplicationJob
  retry_on StandardError, wait: 5.seconds, attempts: 5

  def perform(file_path)
    Rails.logger.info("Starting processing of file: #{file_path}")
    exchange_rates = ExchangeRateFetcher.fetch_rates
    CsvProcessor.new(file_path, exchange_rates).process
    Rails.logger.info("Successfully processed file: #{file_path}")
  rescue StandardError => e
    Rails.logger.error("Error processing file #{file_path}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise e
  end
end
