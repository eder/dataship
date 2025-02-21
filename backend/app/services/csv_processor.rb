require 'csv'
require 'date'
require 'bigdecimal'
require 'bigdecimal/util'
require 'action_view'  # Adicionado para usar helpers de sanitização

class CsvProcessor
  include ActionView::Helpers::SanitizeHelper  # Inclui o método strip_tags

  def initialize(file_path, exchange_rates)
    @file_path = file_path
    @exchange_rates = exchange_rates
  end

  def process
    products = []
    CSV.foreach(@file_path, headers: true, col_sep: ';') do |row|
      name = row['name']&.strip
      price_str = row['price']&.strip
      expiration_str = row['expiration']&.strip

      next unless name.present? && price_str.present? && expiration_str.present?

      name = strip_tags(name)

      sanitized_price = price_str.gsub(/[^\d,\.]/, '')
      price = sanitized_price.tr(',', '.').to_d rescue nil
      next unless price

      expiration = begin
                     Date.strptime(expiration_str, '%m/%d/%Y')
                   rescue ArgumentError
                     nil
                   end
      next unless expiration

      products << {
        name: name,
        price: price,
        expiration: expiration,
        exchange_rates: @exchange_rates,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    Product.insert_all(products) if products.any?
  end
end

