require "csv"
require "date"
require "bigdecimal"
require "bigdecimal/util"
require "action_view"

class CsvProcessor
  include ActionView::Helpers::SanitizeHelper

  BATCH_SIZE = 1000
  MAX_LINES = ENV.fetch("CSV_MAX_LINES", 1_000_000).to_i

  def initialize(file_path, exchange_rates)
    @file_path = file_path
    @exchange_rates = exchange_rates
    failed_dir = Rails.root.join("tmp")
    FileUtils.mkdir_p(failed_dir) unless Dir.exist?(failed_dir)
    @failed_rows_file = failed_dir.join("failed_rows.csv")
    # Initialize the failed rows log file with headers
    File.open(@failed_rows_file, "w") { |f| f.puts "line_number, row_data, error_message" }
  end

  def process
    Rails.logger.info("Starting CSV processing for file: #{@file_path}")

    total_processed = 0
    total_valid = 0
    total_skipped = 0
    current_batch = []

    # Process file in batches to avoid memory issues
    CSV.foreach(@file_path, headers: true, col_sep: ";") do |row|
      total_processed += 1

      # Check if we've reached the maximum lines limit
      if total_processed > MAX_LINES
        Rails.logger.warn("Reached maximum lines limit (#{MAX_LINES}). Stopping processing.")
        break
      end

      begin
        validated = validate_row(total_processed, row)
        if validated
          sanitized = sanitize_row(validated)
          current_batch << sanitized.merge(
            exchange_rates: @exchange_rates,
            created_at: Time.current,
            updated_at: Time.current
          )
          total_valid += 1
        else
          total_skipped += 1
        end

        # Insert batch when it reaches the batch size
        if current_batch.size >= BATCH_SIZE
          insert_batch(current_batch, total_processed)
          Rails.logger.info("Processed batch: #{total_processed} lines, #{total_valid} valid, #{total_skipped} skipped")
          current_batch = []
        end

      rescue StandardError => row_error
        log_failed_row(total_processed, row, "Exception: #{row_error.message}")
        Rails.logger.error("Error processing row ##{total_processed}: #{row_error.message}")
        total_skipped += 1
      end
    end

    # Insert remaining products in the last batch
    if current_batch.any?
      insert_batch(current_batch, total_processed)
    end

    Rails.logger.info(
      "Completed CSV processing: #{total_processed} lines processed, #{total_valid} products inserted, #{total_skipped} rows skipped from file #{@file_path}."
    )
  end

  private

  def validate_row(line_number, row)
    name = row["name"]&.strip
    price_str = row["price"]&.strip
    expiration_str = row["expiration"]&.strip

    unless name.present? && price_str.present? && expiration_str.present?
      error_message = "Missing required fields. name: #{name.inspect}, price: #{price_str.inspect}, expiration: #{expiration_str.inspect}"
      log_failed_row(line_number, row, error_message)
      return nil
    end

    sanitized_price = price_str.gsub(/[^\d,\.]/, "")
    price = sanitized_price.tr(",", ".").to_d rescue nil
    unless price
      error_message = "Invalid price format (#{price_str.inspect} sanitized to #{sanitized_price.inspect})."
      log_failed_row(line_number, row, error_message)
      return nil
    end

    expiration = Date.strptime(expiration_str, "%m/%d/%Y") rescue nil
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

  def insert_batch(products, line_number)
    return if products.empty?

    ActiveRecord::Base.transaction do
      Product.insert_all(products)
    end

    Rails.logger.info("Batch insert completed: #{products.size} products inserted (up to line #{line_number})")
  end

  # Logs a failed row into the failed_rows CSV file with the line number, row data, and error message.
  def log_failed_row(line_number, row, error_message)
    File.open(@failed_rows_file, "a") do |f|
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
