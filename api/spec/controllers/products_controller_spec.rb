require 'rails_helper'

RSpec.describe Api::ProductsController, type: :controller do
  describe 'GET #index' do
    let!(:product) { Product.create!(name: 'Test Product', price: 10.0, expiration: Date.tomorrow, exchange_rates: {}) }

    it 'returns a successful response' do
      get :index, params: {}
      expect(response).to be_successful
    end

    it 'filtra por nome' do
      get :index, params: { name: 'Test' }
      json = JSON.parse(response.body)
      expect(json.first['name']).to eq('Test Product')
    end
  end

  describe 'POST #upload' do
    it 'retuns error if file not exist' do
      post :upload, params: {}
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end

