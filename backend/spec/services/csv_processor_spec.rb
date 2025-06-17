require 'rails_helper'
require 'tempfile'
require 'csv'

RSpec.describe CsvProcessor, type: :service do
  let(:exchange_rates) { { USD: 1.0, EUR: 0.85 } }
  let(:csv_content) do
    <<~CSV
      name;price;expiration
      Valid Product #(123456);$12.34;1/31/2023
      Malicious Product #(bad-content);$56.78;1/15/2023
      Incomplete Product ;;1/15/2023
      Invalid Date Product #(7890);$45.67;31-01-2023
    CSV
  end

  let(:temp_csv_path) do
    file = Tempfile.new(['test_csv', '.csv'])
    file.write(csv_content)
    file.rewind
    path = file.path
    file.close
    path
  end

  after do
    # Clean up the temporary CSV file after tests
    File.delete(temp_csv_path) if File.exist?(temp_csv_path)
    # Clean up the failed rows log file if it exists
    failed_rows_file = Rails.root.join('tmp', 'failed_rows.csv')
    File.delete(failed_rows_file) if File.exist?(failed_rows_file)
    ENV.delete('CSV_MAX_LINES')
  end

  before do
    # Ensure there are no products before running tests
    Product.delete_all
    ENV['CSV_MAX_LINES'] = '1000'
  end

  describe '#process' do
    it 'processes valid rows, sanitizes name field, and logs failed rows' do
      processor = CsvProcessor.new(temp_csv_path, exchange_rates)
      processor.process

      products = Product.all
      # Expect 2 valid products (the Incomplete and Invalid Date rows should be skipped)
      expect(products.count).to eq(2)

      product1 = products.find_by(name: "Valid Product #(123456)")
      expect(product1).not_to be_nil
      expect(product1.price).to eq(12.34.to_d)
      expect(product1.expiration).to eq(Date.strptime("1/31/2023", '%m/%d/%Y'))

      # The name of the second product should have the numeric hash sanitized
      product2 = products.find_by(name: "Malicious Product #()")
      expect(product2).not_to be_nil
      expect(product2.price).to eq(56.78.to_d)
      expect(product2.expiration).to eq(Date.strptime("1/15/2023", '%m/%d/%Y'))

      # Verify that the failed_rows log file was created and contains the failed rows for the incomplete and invalid date products
      failed_rows_file = Rails.root.join('tmp', 'failed_rows.csv')
      expect(File).to exist(failed_rows_file)
      failed_content = File.read(failed_rows_file)
      expect(failed_content).to include("Incomplete Product")
      expect(failed_content).to include("Invalid Date Product")
    end
  end

  describe '#sanitize_numeric_hash_content' do
    it 'preserves numeric content inside "#(…)"' do
      processor = CsvProcessor.new(temp_csv_path, exchange_rates)
      sanitized = processor.send(:sanitize_numeric_hash_content, "Test Product #(123456)")
      expect(sanitized).to eq("Test Product #(123456)")
    end

    it 'replaces non-numeric content inside "#(…)" with "#()"' do
      processor = CsvProcessor.new(temp_csv_path, exchange_rates)
      sanitized = processor.send(:sanitize_numeric_hash_content, "Test Product #(malicious)")
      expect(sanitized).to eq("Test Product #()")
    end

    it 'handles multiple occurrences in the same string' do
      processor = CsvProcessor.new(temp_csv_path, exchange_rates)
      input = "Item A #(123) and Item B #(abc) and Item C #(456)"
      sanitized = processor.send(:sanitize_numeric_hash_content, input)
      expect(sanitized).to eq("Item A #(123) and Item B #() and Item C #(456)")
    end
  end

  describe '#validate_row' do
    it 'returns sanitized data hash for valid row and logs nothing' do
      processor = CsvProcessor.new(temp_csv_path, exchange_rates)
      # Create a valid row manually
      valid_row = CSV.parse('Valid Product #(123456);$12.34;1/31/2023', headers: %w[name price expiration], col_sep: ';').first
      result = processor.send(:validate_row, 1, valid_row)
      expect(result[:name]).to eq('Valid Product #(123456)')
      expect(result[:price]).to eq(12.34.to_d)
      expect(result[:expiration]).to eq(Date.strptime('1/31/2023', '%m/%d/%Y'))
    end

    it 'returns nil for invalid row' do
      processor = CsvProcessor.new(temp_csv_path, exchange_rates)
      invalid_row = CSV.parse('Invalid;;1/31/2023', headers: %w[name price expiration], col_sep: ';').first
      result = processor.send(:validate_row, 1, invalid_row)
      expect(result).to be_nil
    end
  end

  describe '#sanitize_row' do
    it 'removes HTML and sanitizes numeric hash content' do
      processor = CsvProcessor.new(temp_csv_path, exchange_rates)
      data = { name: '<b>Test #(abc) 123</b>', price: 1.to_d, expiration: Date.today }
      sanitized = processor.send(:sanitize_row, data)
      expect(sanitized[:name]).to eq('Test #() 123')
    end
  end

  describe '#insert_batch' do
    it 'inserts products when batch is provided' do
      processor = CsvProcessor.new(temp_csv_path, exchange_rates)
      products = Array.new(100) { { name: 'A', price: 1.to_d, expiration: Date.today } }
      expect(Product).to receive(:insert_all).with(products)
      processor.send(:insert_batch, products, 100)
    end

    it 'does not insert when products array is empty' do
      processor = CsvProcessor.new(temp_csv_path, exchange_rates)
      expect(Product).not_to receive(:insert_all)
      processor.send(:insert_batch, [], 100)
    end
  end
end

