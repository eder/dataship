require 'rails_helper'

RSpec.describe 'Routing', type: :routing do
  # Test for the rails health check route
  it 'routes GET /up to rails/health#show' do
    expect(get: '/up').to route_to(controller: 'rails/health', action: 'show')
  end

  # Test for ActionCable mount
  it 'has a cable mount route at /cable' do
    cable_route = Rails.application.routes.routes.detect do |route|
      route.path.spec.to_s =~ /^\/cable(\.|$)/
    end
    expect(cable_route).not_to be_nil
  end

  describe 'API routes for products' do
    it 'routes GET /api/products to api/products#index' do
      expect(get: '/api/products').to route_to(controller: 'api/products', action: 'index')
    end

    it 'routes POST /api/products/upload to api/products#upload' do
      expect(post: '/api/products/upload').to route_to(controller: 'api/products', action: 'upload')
    end
  end
end
