require 'rails_helper'

RSpec.describe Api::ProductsController, type: :controller do
  describe 'GET #index' do
    before do
      # Limpar produtos existentes antes de criar novos
      Product.delete_all
      
      create_list(:product, 20, exchange_rates: {
        "USD" => 1.0,
        "BRL" => 5.73,
        "CNY" => 7.25,
        "INR" => 86.58,
        "RUB" => 88.50,
        "ZAR" => 18.36
      })
    end

    it 'returns success and meta information with default pagination and product payload with comparisons and currency' do
      get :index
      expect(response).to be_successful

      json = JSON.parse(response.body)
      expect(json['meta']['current_page']).to eq(1)
      expect(json['meta']['per_page']).to eq(10)
      expect(json['meta']['total_results']).to eq(20)
      expect(json['products'].size).to eq(10)

      # Valida o payload de um produto
      product_json = json['products'].first
      expect(product_json).to include(
        "id",
        "name",
        "price",
        "expiration",
        "currency",
        "comparisons"
      )

      expect(product_json["currency"]).to eq("USD")

      base_price = product_json["price"].to_f
      comparisons = product_json["comparisons"]
      expected_comparisons = {
        "USD" => {
          "exchangeRate" => 1.0,
          "price" => (base_price * 1.0).round(8)
        },
        "BRL" => {
          "exchangeRate" => 5.73,
          "price" => (base_price * 5.73).round(8)
        },
        "CNY" => {
          "exchangeRate" => 7.25,
          "price" => (base_price * 7.25).round(8)
        },
        "INR" => {
          "exchangeRate" => 86.58,
          "price" => (base_price * 86.58).round(8)
        },
        "RUB" => {
          "exchangeRate" => 88.50,
          "price" => (base_price * 88.50).round(8)
        },
        "ZAR" => {
          "exchangeRate" => 18.36,
          "price" => (base_price * 18.36).round(8)
        }
      }
      expect(comparisons).to eq(expected_comparisons)
    end

    it 'filters products by name' do
      special_product = create(:product, name: 'Special Product', exchange_rates: {
        "USD" => 1.0,
        "BRL" => 5.73,
        "CNY" => 7.25,
        "INR" => 86.58,
        "RUB" => 88.50,
        "ZAR" => 18.36
      })
      get :index, params: { name: 'Special' }
      json = JSON.parse(response.body)
      expect(json['meta']['total_results']).to be >= 1
      names = json['products'].map { |p| p['name'] }
      expect(names).to include(special_product.name)
    end

    it 'filters products by minimum price' do
      create(:product, price: 150, exchange_rates: {
        "USD" => 1.0,
        "BRL" => 5.73,
        "CNY" => 7.25,
        "INR" => 86.58,
        "RUB" => 88.50,
        "ZAR" => 18.36
      })
      get :index, params: { min_price: 100 }
      json = JSON.parse(response.body)
      expect(json['meta']['total_results']).to be >= 1
    end

    it 'filters products by maximum price' do
      create(:product, price: 50, exchange_rates: {
        "USD" => 1.0,
        "BRL" => 5.73,
        "CNY" => 7.25,
        "INR" => 86.58,
        "RUB" => 88.50,
        "ZAR" => 18.36
      })
      get :index, params: { max_price: 100 }
      json = JSON.parse(response.body)
      expect(json['meta']['total_results']).to be >= 1
    end

    it 'filters products by expiration date starting from a given date' do
      create(:product, expiration: Date.today + 5.days, exchange_rates: {
        "USD" => 1.0,
        "BRL" => 5.73,
        "CNY" => 7.25,
        "INR" => 86.58,
        "RUB" => 88.50,
        "ZAR" => 18.36
      })
      get :index, params: { expiration_from: Date.today.to_s }
      json = JSON.parse(response.body)
      expect(json['meta']['total_results']).to be >= 1
    end

    it 'sorts products by name in descending order' do
      product_a = create(:product, name: 'A Product', exchange_rates: {
        "USD" => 1.0,
        "BRL" => 5.73,
        "CNY" => 7.25,
        "INR" => 86.58,
        "RUB" => 88.50,
        "ZAR" => 18.36
      })
      product_z = create(:product, name: 'Z Product', exchange_rates: {
        "USD" => 1.0,
        "BRL" => 5.73,
        "CNY" => 7.25,
        "INR" => 86.58,
        "RUB" => 88.50,
        "ZAR" => 18.36
      })
      get :index, params: { sort: 'name', order: 'desc' }
      json = JSON.parse(response.body)
      names = json['products'].map { |p| p['name'] }
      expect(names.first).to eq(product_z.name)
    end
  end

  describe 'POST #upload' do
    context 'when file is provided' do
      let(:file) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'standard_file.csv'), 'text/csv') }

      it 'saves the file, enqueues the job, and returns accepted status' do
        expect(CsvProcessingJob).to receive(:perform_later)

        post :upload, params: { file: file }
        expect(response).to have_http_status(:accepted)

        json = JSON.parse(response.body)
        expect(json['message']).to eq("File is being processed")
      end
    end

    context 'when file is not provided' do
      it 'returns an error with unprocessable_entity status' do
        post :upload
        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json['error']).to eq("No file provided")
      end
    end
  end
end
