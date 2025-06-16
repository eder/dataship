require 'csv'
require 'date'
require 'bigdecimal'
require 'bigdecimal/util'
require 'action_view'

class CsvProcessor
  include ActionView::Helpers::SanitizeHelper
  
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
    valid_rows = 0
    skipped_rows = 0
    products = []
    line_number = 0

    parse_rows.each do |ln, row|
      line_number = ln
      break if line_number > max_lines
      begin
        validated = validate_row(line_number, row)
        if validated
          sanitized = sanitize_row(validated)
          products << sanitized.merge(
            exchange_rates: @exchange_rates,
            created_at: Time.current,
            updated_at: Time.current
          )
          valid_rows += 1
          products = batch_insert(products, line_number)
        else
          skipped_rows += 1
        end
      rescue StandardError => row_error
        log_failed_row(line_number, row, "Exception: #{row_error.message}")
        Rails.logger.error("Error processing row ##{line_number}: #{row.inspect}. Error: #{row_error.message}")
        skipped_rows += 1
      end
    end

    Product.insert_all(products) if products.any?
    Rails.logger.info(
      "Processed #{line_number} lines: inserted #{valid_rows} products and skipped #{skipped_rows} rows from file #{@file_path}."
    )
  end

  private

  def parse_rows
    return enum_for(:parse_rows) unless block_given?
    line_number = 0
    CSV.foreach(@file_path, headers: true, col_sep: ';') do |row|
      line_number += 1
      yield line_number, row
    end
  end

  def validate_row(line_number, row)
    name = row['name']&.strip
    price_str = row['price']&.strip
    expiration_str = row['expiration']&.strip

    unless name.present? && price_str.present? && expiration_str.present?
      error_message = "Missing required fields. name: #{name.inspect}, price: #{price_str.inspect}, expiration: #{expiration_str.inspect}"
      log_failed_row(line_number, row, error_message)
      return nil
    end

    sanitized_price = price_str.gsub(/[^\d,\.]/, '')
    price = sanitized_price.tr(',', '.').to_d rescue nil
    unless price
      error_message = "Invalid price format (#{price_str.inspect} sanitized to #{sanitized_price.inspect})."
      log_failed_row(line_number, row, error_message)
      return nil
    end

    expiration = Date.strptime(expiration_str, '%m/%d/%Y') rescue nil
    unless expiration
      error_message = "Invalid expiration date format (#{expiration_str.inspect})."
      log_failed_row(line_number, row, error_message)
      return nil
    end

    { name: name, price: price, expiration: expiration }
  end

  def sanitize_row(data)
    sanitized_name = strip_tags(data[:name])
    sanitized_name = sanitize_numeric_hash_content(sanitized_name)
    { name: sanitized_name, price: data[:price], expiration: data[:expiration] }
  end

  def batch_insert(products, line_number)
    return products unless products.size >= 1000

    Product.insert_all(products)
    Rails.logger.info("Batch insert: inserted #{products.size} products (up to row #{line_number}).")
    []
  end

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

