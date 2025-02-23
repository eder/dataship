# app/services/csv_processor.rb
require 'csv'
require 'date'
require 'bigdecimal'
require 'bigdecimal/util'
require 'action_view'
include ActionView::Helpers::SanitizeHelper

class CsvProcessor
  def initialize(file_path, exchange_rates)
    @file_path = file_path
    @exchange_rates = exchange_rates
    failed_dir = Rails.root.join('tmp')
    FileUtils.mkdir_p(failed_dir) unless Dir.exist?(failed_dir)
    @failed_rows_file = failed_dir.join('failed_rows.csv')
    File.open(@failed_rows_file, 'w') { |f| f.puts "line_number, row_data, error_message" }
  end

  def process
    max_lines = ENV.fetch("CSV_MAX_LINES").to_i
    line_count = 0
    valid_rows = 0
    skipped_rows = 0
    products = []

    CSV.foreach(@file_path, headers: true, col_sep: ';') do |row|
      line_count += 1
      if line_count > max_lines
        Rails.logger.warn("CSV file exceeded the maximum allowed lines (#{max_lines}). Stopping processing.")
        break
      end

      begin
        name = row['name']&.strip
        price_str = row['price']&.strip
        expiration_str = row['expiration']&.strip

        unless name.present? && price_str.present? && expiration_str.present?
          error_message = "Missing required fields. name: #{name.inspect}, price: #{price_str.inspect}, expiration: #{expiration_str.inspect}"
          log_failed_row(line_count, row, error_message)
          skipped_rows += 1
          next
        end

        name = strip_tags(name)
        sanitized_price = price_str.gsub(/[^\d,\.]/, '')
        price = sanitized_price.tr(',', '.').to_d rescue nil
        unless price
          error_message = "Invalid price format (#{price_str.inspect} sanitized to #{sanitized_price.inspect})."
          log_failed_row(line_count, row, error_message)
          skipped_rows += 1
          next
        end

        expiration = Date.strptime(expiration_str, '%m/%d/%Y') rescue nil
        unless expiration
          error_message = "Invalid expiration date format (#{expiration_str.inspect})."
          log_failed_row(line_count, row, error_message)
          skipped_rows += 1
          next
        end

        products << {
          name: name,
          price: price,
          expiration: expiration,
          exchange_rates: @exchange_rates,
          created_at: Time.current,
          updated_at: Time.current
        }
        valid_rows += 1

        # Batch insert for every 1000 valid rows
        if products.size >= 1000
          Product.insert_all(products)
         Rails.logger.info("Batch insert: inserted #{products.size} products (up to row #{line_count}).")
          products = []
        end
      rescue StandardError => row_error
        error_message = "Exception: #{row_error.message}"
        log_failed_row(line_count, row, error_message)
        Rails.logger.error("Error processing row ##{line_count}: #{row.inspect}. Error: #{row_error.message}")
        skipped_rows += 1
      end
    end

    Product.insert_all(products) if products.any?
    Rails.logger.info("Processed #{line_count} lines: inserted #{valid_rows} products and skipped #{skipped_rows} rows from file #{@file_path}.")
  end

  private

  def log_failed_row(line_number, row, error_message)
    File.open(@failed_rows_file, 'a') do |f|
      f.puts "#{line_number}, #{row.to_h.to_json}, #{error_message}"
    end
  rescue => e
    Rails.logger.error("Failed to log row ##{line_number}: #{e.message}")
  end
end

