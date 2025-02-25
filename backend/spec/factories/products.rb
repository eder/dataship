FactoryBot.define do
  factory :product do
    name { "Test Product" }
    price { rand(10..100) }
    expiration { Date.today + rand(1..30).days }
  end
end
