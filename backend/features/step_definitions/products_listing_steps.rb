Given("there are {int} products in the database") do |total|
  total.times do |i|
    Product.create!(
      name: "Test Product #{i}",
      price: (i + 1) * 10.0,
      expiration: (Date.today + i.days).strftime('%m/%d/%Y'),
      exchange_rates: {
        "USD" => 1.0,
        "BRL" => 5.0,
        "CNY" => 7.0,
        "INR" => 80.0,
        "RUB" => 90.0,
        "ZAR" => 18.0
      }
    )
  end
  puts "Total products inserted: #{Product.count}"
end
