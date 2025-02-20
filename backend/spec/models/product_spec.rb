# spec/models/product_spec.rb
require 'rails_helper'

RSpec.describe Product, type: :model do
  it 'is valid with valid attributes' do
    product = Product.new(name: 'Test', price: 10.0, expiration: Date.tomorrow, exchange_rates: {})
    expect(product).to be_valid
  end

  it 'is invalid without a name' do
    product = Product.new(price: 10.0, expiration: Date.tomorrow, exchange_rates: {})
    expect(product).not_to be_valid
  end
end

