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
    # Initialize the failed rows log file with headers
    File.open(@failed_rows_file, 'w') { |f| f.puts "line_number, row_data, error_message" }
  end

  def process
    max_lines = ENV.fetch("CSV_MAX_LINES").to_i
    line_count = 0
    valid_rows = 0
    skipped_rows = 0
    products = []

    # Iterate over each row in the CSV file using a semicolon as the column separator
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

        # Check that required fields are present
        unless name.present? && price_str.present? && expiration_str.present?
          error_message = "Missing required fields. name: #{name.inspect}, price: #{price_str.inspect}, expiration: #{expiration_str.inspect}"
          log_failed_row(line_count, row, error_message)
          skipped_rows += 1
          next
        end

        # Remove any HTML tags from the name field
        name = strip_tags(name)
        # Sanitize any occurrences of #(…) in the name field:
        # If the content inside is not numeric, it will be replaced by "#()"
        name = sanitize_numeric_hash_content(name)

        # Sanitize the price string: remove non-numeric characters except comma and dot
        sanitized_price = price_str.gsub(/[^\d,\.]/, '')
        # Convert to a BigDecimal (replace comma with dot if necessary)
        price = sanitized_price.tr(',', '.').to_d rescue nil
        unless price
          error_message = "Invalid price format (#{price_str.inspect} sanitized to #{sanitized_price.inspect})."
          log_failed_row(line_count, row, error_message)
          skipped_rows += 1
          next
        end

        # Parse the expiration date from the provided string (format: MM/DD/YYYY)
        expiration = Date.strptime(expiration_str, '%m/%d/%Y') rescue nil
        unless expiration
          error_message = "Invalid expiration date format (#{expiration_str.inspect})."
          log_failed_row(line_count, row, error_message)
          skipped_rows += 1
          next
        end

        # Prepare the product data hash for bulk insertion
        products << {
          name: name,
          price: price,
          expiration: expiration,
          exchange_rates: @exchange_rates,
          created_at: Time.current,
          updated_at: Time.current
        }
        valid_rows += 1

        # Insert products in batches of 1000
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

    # Insert any remaining products
    Product.insert_all(products) if products.any?
    Rails.logger.info("Processed #{line_count} lines: inserted #{valid_rows} products and skipped #{skipped_rows} rows from file #{@file_path}.")
  end

  private

  # Logs a failed row into the failed_rows CSV file with the line number, row data, and error message.
  def log_failed_row(line_number, row, error_message)
    File.open(@failed_rows_file, 'a') do |f|
      f.puts "#{line_number}, #{row.to_h.to_json}, #{error_message}"
    end
  rescue => e
    Rails.logger.error("Failed to log row ##{line_number}: #{e.message}")
  end

  # Sanitizes any occurrences of the pattern "#(…)" in the given string.
  # If the content inside "#(…)" is not solely numeric, it is replaced by "#()".
  def sanitize_numeric_hash_content(str)
    str.gsub(/#\(([^)]*)\)/) do
      inner_content = Regexp.last_match(1)
      inner_content.match?(/\A\d+\z/) ? "#(#{inner_content})" : "#()"
    end
  end
end

