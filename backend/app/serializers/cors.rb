Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:5001', 'http://localhost:5173'
   origins '*' 
    resource '*',
      headers: :any,
      methods: %i[:get, :post, :put, :patch, :delete, :options, :head],
      credentials: false,
      expose: ['Authorization']
  end
end

