# frozen_string_literal: true

require 'rails_helper'
require 'tempfile'

RSpec.describe CsvProcessingJob, type: :job do
  let(:exchange_rates) do
    # Simulate hash de exchange rates
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

  before do
    allow(ExchangeRateFetcher).to receive(:fetch_rates).and_return(exchange_rates)
    allow(NotificationService).to receive(:new).and_return(notification_service)
    allow(notification_service).to receive(:notify).and_return(true)
  end

  it "processes a valid CSV and inserts products" do
    file = Tempfile.new(['test_products', '.csv'])
    file.write(csv_content)
    file.rewind

    expect {
      CsvProcessingJob.perform_now(file.path)
    }.to change { Product.count }.by(2)

    expect(notification_service).to have_received(:notify).with(
      "File processing finished successfully",
      hash_including(
        file: file.path,
        status: "success"
      )
    )

    file.close
    file.unlink
  end

  it "logs and skips invalid rows" do
    invalid_csv = <<~CSV
      name;price;expiration
      Invalid Product;;12/31/2025
      Another Product;$30.00;invalid_date
    CSV
    file = Tempfile.new(['invalid_products', '.csv'])
    file.write(invalid_csv)
    file.rewind

    expect {
      CsvProcessingJob.perform_now(file.path)
    }.to change { Product.count }.by(0)

    expect(notification_service).to have_received(:notify).with(
      "File processing finished successfully",
      hash_including(
        file: file.path,
        status: "success"
      )
    )

    file.close
    file.unlink
  end

  it "allows custom notification adapter configuration" do
    file = Tempfile.new(['test_products', '.csv'])
    file.write(csv_content)
    file.rewind

    custom_config = { topic_arn: 'arn:aws:sns:us-east-1:123456789012:my-topic' }
    
    expect(NotificationService).to receive(:new).with('aws_sns', custom_config).and_return(notification_service)

    CsvProcessingJob.perform_now(file.path, 'aws_sns', custom_config)

    file.close
    file.unlink
  end
end

