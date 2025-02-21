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
  end

  def process
    products = []
    CSV.foreach(@file_path, headers: true, col_sep: ';') do |row|
      begin
        name = row['name']&.strip
        price_str = row['price']&.strip
        expiration_str = row['expiration']&.strip

        next unless name.present? && price_str.present? && expiration_str.present?

        name = strip_tags(name)

        sanitized_price = price_str.gsub(/[^\d,\.]/, '')
        price = sanitized_price.tr(',', '.').to_d rescue nil
        next unless price

        expiration = Date.strptime(expiration_str, '%m/%d/%Y') rescue nil
        next unless expiration

        products << {
          name: name,
          price: price,
          expiration: expiration,
          exchange_rates: @exchange_rates,
          created_at: Time.current,
          updated_at: Time.current
        }
      rescue StandardError => row_error
        Rails.logger.error("Error processing row: #{row.inspect}. Error: #{row_error.message}")
      end
    end

    if products.any?
      Product.insert_all(products)
      Rails.logger.info("Inserted #{products.size} products successfully from file #{@file_path}.")
    else
      Rails.logger.warn("No products were inserted from file #{@file_path}.")
    end
  end
end
