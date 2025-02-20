FactoryBot.define do
  factory :product do
    name { "Product Name" }
    price { 9.99 }
    expiration { Date.today + 30 }
    exchange_rates { { "USD" => 5.0, "EUR" => 5.5 } }
  end
end
