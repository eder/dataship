require 'rails_helper'

RSpec.describe "Products API", type: :request do
  before do
    @product = Product.create!(
      name: "Cheese - Brie, Cups 125g #(4017956126189774)",
      price: 0.41,
      expiration: Date.parse("2022-12-19"),
      exchange_rates: {
        "USD" => 1.0,
        "BRL" => 5.73,
        "CNY" => 7.25,
        "INR" => 86.58,
        "RUB" => 88.50,
        "ZAR" => nil  # Example: Invalid rate (nil) for ZAR
      }
    )
  end

  describe "GET /api/products" do
    it "returns a product with the correct payload structure" do
      get "/api/products", params: { page: 1, per_page: 10, sort: "name", order: "asc" }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json).to have_key("meta")
      expect(json).to have_key("products")

      product_json = json["products"].first
      expect(product_json["id"]).to eq(@product.id)
      expect(product_json["name"]).to eq(@product.name)
      expect(product_json["price"]).to eq(0.41)
      expect(product_json["currency"]).to eq("USD")
      expect(product_json["expiration"]).to eq(@product.expiration.strftime("%Y-%m-%d"))

      expect(product_json).to have_key("comparisons")
      comparisons = product_json["comparisons"]

      expect(comparisons["USD"]["exchangeRate"]).to eq(1.0)
      expect(comparisons["USD"]["price"]).to eq((0.41 * 1.0).round(8))

      expect(comparisons["BRL"]["exchangeRate"]).to eq(5.73)
      expect(comparisons["BRL"]["price"]).to eq((0.41 * 5.73).round(8))

      expect(comparisons["CNY"]["exchangeRate"]).to eq(7.25)
      expect(comparisons["CNY"]["price"]).to eq((0.41 * 7.25).round(8))

      expect(comparisons["INR"]["exchangeRate"]).to eq(86.58)
      expect(comparisons["INR"]["price"]).to eq((0.41 * 86.58).round(8))

      expect(comparisons["RUB"]["exchangeRate"]).to eq(88.50)
      expect(comparisons["RUB"]["price"]).to eq((0.41 * 88.50).round(8))

      expect(comparisons["ZAR"]["exchangeRate"]).to be_nil
      expect(comparisons["ZAR"]["price"]).to be_nil
    end
  end
end

