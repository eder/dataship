require 'rails_helper'

RSpec.describe Api::ProductsController, type: :controller do
  describe 'GET #index' do
    before do
      # Create 20 products for testing
      create_list(:product, 20)
    end

    it 'returns success and meta information with default pagination' do
      get :index
      expect(response).to be_successful

      json = JSON.parse(response.body)
      expect(json['meta']['current_page']).to eq(1)
      expect(json['meta']['per_page']).to eq(10)
      expect(json['meta']['total_results']).to eq(20)
      expect(json['products'].size).to eq(10)
    end

    it 'filters products by name' do
      # Create a product with a specific name
      create(:product, name: 'Special Product')
      get :index, params: { name: 'Special' }
      json = JSON.parse(response.body)
      expect(json['meta']['total_results']).to be >= 1
    end

    it 'filters products by minimum price' do
      # Create a product with a set price
      create(:product, price: 150)
      get :index, params: { min_price: 100 }
      json = JSON.parse(response.body)
      expect(json['meta']['total_results']).to be >= 1
    end

    it 'filters products by maximum price' do
      create(:product, price: 50)
      get :index, params: { max_price: 100 }
      json = JSON.parse(response.body)
      expect(json['meta']['total_results']).to be >= 1
    end

    it 'filters products by expiration date starting from a given date' do
      # Assuming the expiration attribute is a date
      create(:product, expiration: Date.today + 5.days)
      get :index, params: { expiration_from: Date.today.to_s }
      json = JSON.parse(response.body)
      expect(json['meta']['total_results']).to be >= 1
    end

    it 'sorts products by name in descending order' do
      product_a = create(:product, name: 'A Product')
      product_z = create(:product, name: 'Z Product')
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
