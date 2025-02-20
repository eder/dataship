require 'rails_helper'

RSpec.describe "Products API", type: :request do
  let!(:products) { create_list(:product, 5) }
  let(:product_id) { products.first.id }

  describe "GET /products" do
    it "returns all products" do
      get "/products"
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).size).to eq(5)
    end
  end

  describe "GET /products/:id" do
    it "returns the product" do
      get "/products/#{product_id}"
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["id"]).to eq(product_id)
    end
  end

  describe "POST /products" do
    let(:valid_attributes) { { name: "New Product", price: 19.99, expiration: "2025-01-01", exchange_rates: { "USD" => 5.0 } } }

    it "creates a new product" do
      expect {
        post "/products", params: { product: valid_attributes }
      }.to change(Product, :count).by(1)

      expect(response).to have_http_status(201)
    end
  end

  describe "PUT /products/:id" do
    let(:new_attributes) { { name: "Updated Name" } }

    it "updates the product" do
      put "/products/#{product_id}", params: { product: new_attributes }
      expect(response).to have_http_status(200)
      expect(Product.find(product_id).name).to eq("Updated Name")
    end
  end

  describe "DELETE /products/:id" do
    it "deletes the product" do
      expect {
        delete "/products/#{product_id}"
      }.to change(Product, :count).by(-1)

      expect(response).to have_http_status(204)
    end
  end
end
