require 'rails_helper'

RSpec.describe Product, type: :model do
  it "is valid with valid attributes" do
    product = build(:product)
    expect(product).to be_valid
  end

  it "is invalid without a name" do
    product = build(:product, name: nil)
    expect(product).to be_invalid
  end

  it "is invalid without a price" do
    product = build(:product, price: nil)
    expect(product).to be_invalid
  end

  it "is invalid without an expiration date" do
    product = build(:product, expiration: nil)
    expect(product).to be_invalid
  end

  it "has a default exchange_rates value of an empty hash" do
    product = Product.new
    expect(product.exchange_rates).to eq({})
  end
end
