require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'scopes' do
    before do
      @product1 = create(:product, name: "Apple", price: 100, expiration: Date.today + 10.days)
      @product2 = create(:product, name: "Banana", price: 200, expiration: Date.today + 20.days)
      @product3 = create(:product, name: "Carrot", price: 300, expiration: Date.today + 30.days)
    end

    describe '.by_name' do
      it 'returns products that match the given name case-insensitively' do
        expect(Product.by_name("app")).to include(@product1)
        expect(Product.by_name("app")).not_to include(@product2)
      end

      it 'returns all products when name is not provided' do
        expect(Product.by_name(nil)).to eq(Product.all)
      end
    end

    describe '.min_price' do
      it 'returns products with a price greater than or equal to the given value' do
        expect(Product.min_price(200)).to include(@product2, @product3)
        expect(Product.min_price(200)).not_to include(@product1)
      end

      it 'returns all products when price is not provided' do
        expect(Product.min_price(nil)).to eq(Product.all)
      end
    end

    describe '.max_price' do
      it 'returns products with a price less than or equal to the given value' do
        expect(Product.max_price(200)).to include(@product1, @product2)
        expect(Product.max_price(200)).not_to include(@product3)
      end

      it 'returns all products when price is not provided' do
        expect(Product.max_price(nil)).to eq(Product.all)
      end
    end

    describe '.sorted' do
      it 'returns products sorted by the given field and order' do
        sorted_products = Product.sorted('price', 'desc')
        # Verify that the first product in the sorted list is the one with the highest price
        expect(sorted_products.first).to eq(Product.order(price: :desc).first)
      end

      it 'returns all products when an unsupported field is provided' do
        expect(Product.sorted('unsupported_field', 'asc')).to eq(Product.all)
      end
    end
  end
end
