# frozen_string_literal: true

require 'rails_helper'
require 'tempfile'

RSpec.describe CsvProcessingOrchestrator do
  let(:exchange_rates) do
    { "USD" => 1.0, "BRL" => 5.71473278, "CNY" => 7.25113273, "INR" => 86.69044436, "RUB" => 88.81525395, "ZAR" => 18.36307 }
  end

  let(:csv_content) do
    <<~CSV
      name;price;expiration
      Test Product 1;$10.50;12/31/2025
      Test Product 2;$20.00;01/15/2026
    CSV
  end

  let(:notification_service) { instance_double(NotificationService) }
  let(:file_path) { create_temp_file(csv_content) }

  before do
    allow(ExchangeRateFetcher).to receive(:fetch_rates).and_return(exchange_rates)
    allow(NotificationService).to receive(:new).and_return(notification_service)
    allow(notification_service).to receive(:notify).and_return(true)
  end

  after do
    File.delete(file_path) if File.exist?(file_path)
  end

  describe '#process' do
    it 'successfully processes a CSV file' do
      orchestrator = described_class.new(file_path)

      expect {
        orchestrator.process
      }.to change { Product.count }.by(2)

      expect(notification_service).to have_received(:notify).with(
        "File processing finished successfully",
        hash_including(
          file: file_path,
          status: "success"
        )
      )
    end

    it 'raises error when file does not exist' do
      orchestrator = described_class.new('non_existent_file.csv')

      expect {
        orchestrator.process
      }.to raise_error(ArgumentError, "File not found: non_existent_file.csv")
    end

    it 'notifies on processing error and re-raises the error' do
      allow_any_instance_of(CsvProcessor).to receive(:process).and_raise(StandardError, "Processing failed")

      orchestrator = described_class.new(file_path)

      expect {
        orchestrator.process
      }.to raise_error(StandardError, "Processing failed")

      expect(notification_service).to have_received(:notify).with(
        "Error processing file",
        hash_including(
          file: file_path,
          status: "error",
          error: "Processing failed"
        )
      )
    end

    it 'uses custom notification configuration' do
      custom_config = { topic_arn: 'arn:aws:sns:us-east-1:123456789012:my-topic' }
      
      expect(NotificationService).to receive(:new).with('aws_sns', custom_config).and_return(notification_service)

      orchestrator = described_class.new(file_path, 'aws_sns', custom_config)
      orchestrator.process
    end
  end

  private

  def create_temp_file(content)
    file = Tempfile.new(['test_products', '.csv'])
    file.write(content)
    file.rewind
    file.path
  end
end 