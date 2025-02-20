class Product < ApplicationRecord
  validates :name, :price, :expiration, presence: true
end
