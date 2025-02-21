class CsvProcessingJob < ApplicationJob
  queue_as :default

  def perform(file_path)
    exchange_rates = ExchangeRateFetcher.fetch_rates
    CsvProcessor.new(file_path, exchange_rates).process
  end
end
