require 'rails_helper'

RSpec.describe "Products API", type: :request do
  describe "GET /api/products" do
    before do
      15.times do |i|
        Product.create!(
          name: "Product #{i}",
          price: (i + 1) * 10.0,
          expiration: Date.today + i.days,
          exchange_rates: { "USD" => 1.0, "BRL" => 5.0, "CNY" => 7.0, "INR" => 80.0, "RUB" => 90.0, "ZAR" => 18.0 }
        )
      end
    end

    it "returns paginated products with meta data" do
      get "/api/products", params: { page: 2, per_page: 5, sort: "name", order: "asc" }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json).to have_key("meta")
      expect(json["meta"]["current_page"]).to eq(2)
      expect(json["meta"]["per_page"]).to eq(5)
      expect(json).to have_key("products")
      expect(json["products"].size).to eq(5)
    end

    it "applies filters correctly" do
      get "/api/products", params: { name: "Product 1" }
      json = JSON.parse(response.body)
      json["products"].each do |product|
        expect(product["name"]).to include("Product 1")
      end
    end
  end
end
