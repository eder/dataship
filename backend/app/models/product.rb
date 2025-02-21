class Product < ApplicationRecord
  scope :by_name, ->(name) { where("name ILIKE ?", "%#{name}%") if name.present? }
  scope :min_price, ->(price) { where("price >= ?", price) if price.present? }
  scope :max_price, ->(price) { where("price <= ?", price) if price.present? }
  scope :sorted, ->(field, order = 'asc') { order(field => order) if %w[name price expiration].include?(field) }
end
