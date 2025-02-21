class Product < ApplicationRecord
  validates :name, presence: true
  validates :price, numericality: true
  validates :expiration, presence: true
end

